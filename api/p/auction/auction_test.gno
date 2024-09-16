package auction

import (
	"std"
	"testing"
	"time"

	"gno.land/p/demo/ufmt"
)

func TestNewAuction(t *testing.T) {
	owner := std.Address("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := uint64(100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	if auction.Title != "Test Auction" {
		t.Fatalf("expected auction title to be 'Test Auction', got '%s'", auction.Title)
	}
	if auction.Owner != owner {
		t.Fatalf("expected auction owner to be '%s', got '%s'", owner, auction.Owner)
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
	if auction.Price != minPrice {
		t.Fatalf("expected auction price to be '%d', got '%d'", minPrice, auction.Price)
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
	minPrice := uint64(100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	std.TestSetOrigCaller(bidder1)

	// Test before auction starts
	err := auction.AddBid(bidder1, 200)
	if err == nil || err.Error() != "auction: AddBid: auction has not started yet" {
		t.Fatalf("expected error 'auction has not started yet', got '%v'", err)
	}

	// Test successful bid after auction begins (manually adjusting the time)
	auction.Begin = time.Now().Add(-1 * time.Second)
	err = auction.AddBid(bidder1, 200)
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.Price != 200 {
		t.Fatalf("expected auction price to be '200', got '%d'", auction.Price)
	}
	if len(auction.Bids) != 1 {
		t.Fatalf("expected number of bids to be '1', got '%d'", len(auction.Bids))
	}
	if auction.Bids[0].Bidder != bidder1 {
		t.Fatalf("expected bidder to be 'bidder1', got '%s'", auction.Bids[0].Bidder)
	}

	std.TestSetOrigCaller(bidder2)

	// Test higher bid
	err = auction.AddBid(bidder2, 300)
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.Price != 300 {
		t.Fatalf("expected auction price to be '300', got '%d'", auction.Price)
	}
	if len(auction.Bids) != 2 {
		t.Fatalf("expected number of bids to be '2', got '%d'", len(auction.Bids))
	}
	if auction.Bids[1].Bidder != bidder2 {
		t.Fatalf("expected bidder to be 'bidder2', got '%s'", auction.Bids[1].Bidder)
	}

	// Test bid lower than current price
	err = auction.AddBid(bidder1, 250)
	if err == nil || err.Error() != "auction: AddBid: bid amount must be higher than the current highest bid" {
		t.Fatalf("expected error 'bid amount must be higher than the current highest bid', got '%v'", err)
	}
	// Test adding a bid to a closed auction
	auction.State = "closed"
	err = auction.AddBid(bidder2, 400)
	if err == nil || err.Error() != "auction: AddBid: auction is closed" {
		t.Fatalf("expected error 'auction is closed', got '%v'", err)
	}
	auction.State = "ongoing"
	err = auction.AddBid(bidder1, auction.Price)
	if err == nil || err.Error() != "auction: AddBid: bid amount must be higher than the current highest bid" {
		t.Fatalf("expected error 'bid amount must be higher than the current highest bid', got '%v'", err)
	}
}

func TestEndAuction(t *testing.T) {
	owner := std.Address("owner")
	nonOwner := std.Address("nonOwner")
	bidder := std.Address("bidder")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := uint64(100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	// Test ending auction before it starts
	err := auction.EndAuction(owner)
	if err == nil || err.Error() != "auction: EndAuction: auction cannot end before the end time" {
		t.Fatalf("expected error 'auction cannot end before the end time', got '%v'", err)
	}
	// Test ending an auction that has not started yet
	auction.Begin = time.Now().Add(1 * time.Hour) // L'enchère commence dans une heure
	err = auction.EndAuction(owner)
	if err == nil || err.Error() != "auction: EndAuction: auction cannot end before the end time" {
		t.Fatalf("expected error 'auction cannot end before the end time', got '%v'", err)
	}

	// Test ending auction with no bids after it ends
	auction.End = time.Now().Add(-1 * time.Second)
	err = auction.EndAuction(owner)
	if err == nil || err.Error() != "auction: EndAuction: auction ended with no bids" {
		t.Fatalf("expected error 'auction ended with no bids', got '%v'", err)
	}

	// Simulate the end of the auction with a winner
	auction.Bids = append(auction.Bids, &Bid{Bidder: bidder, Amount: 150})
	err = auction.EndAuction(owner)
	if err != nil {
		t.Fatalf("expected no error, got '%v'", err)
	}
	if auction.State != "closed" {
		t.Fatalf("expected auction state to be 'closed', got '%s'", auction.State)
	}
	if auction.Bids[len(auction.Bids)-1].Bidder != bidder {
		t.Fatalf("expected winner to be 'bidder', got '%s'", auction.Bids[len(auction.Bids)-1].Bidder)
	}
	// Test ending auction by non-owner

	err = auction.EndAuction(nonOwner)
	if err == nil || err.Error() != "auction: EndAuction: only the owner can end the auction" {
		t.Fatalf("expected error 'only the owner can end the auction', got '%v'", err)
	}
}
