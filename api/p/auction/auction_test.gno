package auction

import (
	"std"
	"testing"
	"time"
)

func TestNewAuction(t *testing.T) {
	owner := std.Address("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("testcoin", 100) // Utilisation de std.Coin

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	if auction.Title != "Test Auction" {
		t.Fatalf("expected auction title to be 'Test Auction', got '%s'", auction.Title)
	}
	if auction.Ownable.Owner() != owner {
		t.Fatalf("expected auction owner to be '%s', got '%s'", owner, auction.Ownable.Owner())
	}
	if auction.Description != "This is a test auction" {
		t.Fatalf("expected auction description to be 'This is a test auction', got '%s'", auction.Description)
	}
	if auction.Begin != begin {
		t.Fatalf("expected auction begin time to be '%s', got '%s'", begin, auction.Begin)
	}
	if auction.End != end {
		t.Fatalf("expected auction end time to be '%s', got '%s'", end, auction.End)
	}
	if !auction.Price.IsEqual(minPrice) {
		t.Fatalf("expected auction price to be '%s', got '%s'", minPrice.String(), auction.Price.String())
	}
	if auction.State != "upcoming" {
		t.Fatalf("expected auction state to be 'upcoming', got '%s'", auction.State)
	}
}

func TestAddBid(t *testing.T) {
	owner := std.Address("owner")
	bidder1 := std.Address("bidder1")
	bidder2 := std.Address("bidder2")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("default", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)
	std.TestSetOrigCaller(bidder1)

	// Test before auction starts
	err := auction.AddBid(bidder1, std.NewCoin("default", 200))
	if err == nil || err.Error() != "auction: AddBid: auction has not started yet" {
		t.Fatalf("expected error 'auction has not started yet', got '%v'", err)
	}

	// Test successful bid after auction begins
	auction.Begin = time.Now().Add(-1 * time.Second)
	err = auction.AddBid(bidder1, std.NewCoin("default", 200))
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.Price.Amount != 200 {
		t.Fatalf("expected auction price to be '200', got '%d'", auction.Price.Amount)
	}
	if len(auction.Bids) != 1 {
		t.Fatalf("expected number of bids to be '1', got '%d'", len(auction.Bids))
	}
	if auction.Bids[0].Bidder != bidder1 {
		t.Fatalf("expected bidder to be 'bidder1', got '%s'", auction.Bids[0].Bidder)
	}

	std.TestSetOrigCaller(bidder2)

	// Test higher bid
	err = auction.AddBid(bidder2, std.NewCoin("default", 300))
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.Price.Amount != 300 {
		t.Fatalf("expected auction price to be '300', got '%d'", auction.Price.Amount)
	}
	if len(auction.Bids) != 2 {
		t.Fatalf("expected number of bids to be '2', got '%d'", len(auction.Bids))
	}
	if auction.Bids[1].Bidder != bidder2 {
		t.Fatalf("expected bidder to be 'bidder2', got '%s'", auction.Bids[1].Bidder)
	}

	// Test bid lower than current price
	err = auction.AddBid(bidder1, std.NewCoin("default", 250))
	if err == nil || err.Error() != "auction: AddBid: bid amount must be higher than the current highest bid" {
		t.Fatalf("expected error 'bid amount must be higher than the current highest bid', got '%v'", err)
	}
}

func TestGetPaginatedBids(t *testing.T) {
	owner := std.Address("owner")
	begin := time.Now().Add(-1 * time.Hour)
	end := time.Now().Add(1 * time.Hour)
	minPrice := std.NewCoin("default", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	// Add some bids
	bidder1 := std.Address("bidder1")
	bidder2 := std.Address("bidder2")
	bidder3 := std.Address("bidder3")

	auction.AddBid(bidder1, std.NewCoin("default", 150))
	auction.AddBid(bidder2, std.NewCoin("default", 200))
	auction.AddBid(bidder3, std.NewCoin("default", 250))

	// Test the first page with a page size of 2
	bids, err := auction.GetPaginatedBids(1, 2)
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if len(bids) != 2 {
		t.Fatalf("expected 2 bids, got %d", len(bids))
	}

	// Test the second page with a page size de 2
	bids, err = auction.GetPaginatedBids(2, 2)
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if len(bids) != 1 {
		t.Fatalf("expected 1 bid, got %d", len(bids))
	}

	// Test invalid page
	bids, err = auction.GetPaginatedBids(3, 2)
	if err == nil || err.Error() != "page exceeds total number of bids" {
		t.Fatalf("expected error 'page exceeds total number of bids', got '%v'", err)
	}

	// Test for invalid pagination parameters
	_, err = auction.GetPaginatedBids(0, 2)
	if err == nil || err.Error() != "invalid pagination parameters" {
		t.Fatalf("expected error 'invalid pagination parameters', got '%v'", err)
	}
}

func TestEndAuction(t *testing.T) {
	owner := std.Address("owner")
	nonOwner := std.Address("nonOwner")
	bidder := std.Address("bidder")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("token", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	// Set the original caller as the owner for this test
	std.TestSetOrigCaller(owner)

	err := auction.EndAuction()
	if err == nil || err.Error() != "auction: EndAuction: auction cannot end before the end time" {
		t.Fatalf("expected error 'auction cannot end before the end time', got '%v'", err)
	}

	// Test ending the auction with no bids after it has ended
	auction.End = time.Now().Add(-1 * time.Second)
	err = auction.EndAuction()
	if err == nil || err.Error() != "auction: EndAuction: auction ended with no bids" {
		t.Fatalf("expected error 'auction ended with no bids', got '%v'", err)
	}

	// Simulate ending the auction with a winner
	auction.Bids = append(auction.Bids, &Bid{Bidder: bidder, Amount: 150})
	err = auction.EndAuction()
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.State != "closed" {
		t.Fatalf("expected auction state to be 'closed', got '%s'", auction.State)
	}
	if auction.Bids[len(auction.Bids)-1].Bidder != bidder {
		t.Fatalf("expected winner to be 'bidder', got '%s'", auction.Bids[len(auction.Bids)-1].Bidder)
	}

	// Set the original caller as a non-owner and test ending the auction
	std.TestSetOrigCaller(nonOwner)

	err = auction.EndAuction()
	if err == nil || err.Error() != "auction: EndAuction: only the owner can end the auction" {
		t.Fatalf("expected error 'only the owner can end the auction', got '%v'", err)
	}
}
