package auction

import (
	"std"
	"testing"
	"time"

	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
	"gno.land/p/demo/ufmt"
)

func TestNewAuction(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("testcoin", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	uassert.Equal(t, "Test Auction", auction.Title, "Auction title mismatch")
	uassert.Equal(t, owner, auction.Ownable.Owner(), "Auction owner mismatch")
	uassert.Equal(t, "This is a test auction", auction.Description, "Auction description mismatch")
	uassert.Equal(t, begin.String(), auction.Begin.String(), "Auction begin time mismatch")
	uassert.Equal(t, end.String(), auction.End.String(), "Auction end time mismatch")
	uassert.True(t, auction.Price.IsEqual(minPrice), "Auction price mismatch")
	uassert.Equal(t, "upcoming", auction.State, "Auction state mismatch")
}

func TestAddBid(t *testing.T) {
	owner := testutils.TestAddress("owner")
	bidder1 := testutils.TestAddress("bidder1")
	bidder2 := testutils.TestAddress("bidder2")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("default", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)
	std.TestSetOrigCaller(bidder1)

	// Test before auction starts
	err := auction.AddBid(bidder1, std.NewCoin("default", 200))
	uassert.ErrorContains(t, err, "auction has not started yet", "Expected 'auction has not started yet' error")

	// Test successful bid after auction begins
	auction.Begin = time.Now().Add(-1 * time.Second)
	err = auction.AddBid(bidder1, std.NewCoin("default", 200))
	uassert.NoError(t, err, "Expected no error for valid bid")
	uassert.Equal(t, int64(200), auction.Price.Amount, "Auction price mismatch after first bid")
	uassert.Equal(t, 1, len(auction.Bids), "Expected one bid")
	uassert.Equal(t, bidder1, auction.Bids[0].Bidder, "Bidder mismatch")

	std.TestSetOrigCaller(bidder2)

	// Test higher bid
	err = auction.AddBid(bidder2, std.NewCoin("default", 300))
	uassert.NoError(t, err, "Expected no error for valid higher bid")
	uassert.Equal(t, int64(300), auction.Price.Amount, "Auction price mismatch after second bid")
	uassert.Equal(t, 2, len(auction.Bids), "Expected two bids")
	uassert.Equal(t, bidder2, auction.Bids[1].Bidder, "Bidder mismatch")

	// Test bid lower than current price
	err = auction.AddBid(bidder1, std.NewCoin("default", 250))
	uassert.ErrorContains(t, err, "bid amount must be higher than the current highest bid", "Expected error for lower bid")
}

func TestGetPaginatedBids(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(-1 * time.Hour)
	end := time.Now().Add(1 * time.Hour)
	minPrice := std.NewCoin("default", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	// Add some bids
	bidder1 := testutils.TestAddress("bidder1")
	bidder2 := testutils.TestAddress("bidder2")
	bidder3 := testutils.TestAddress("bidder3")

	auction.AddBid(bidder1, std.NewCoin("default", 150))
	auction.AddBid(bidder2, std.NewCoin("default", 200))
	auction.AddBid(bidder3, std.NewCoin("default", 250))

	// Test the first page with a size of 2
	bids, err := auction.GetPaginatedBids(1, 2)
	uassert.NoError(t, err, "Expected no error on fetching first page of bids")
	uassert.Equal(t, 2, len(bids), "Expected 2 bids on the first page")

	// Test the second page with a size of 2
	bids, err = auction.GetPaginatedBids(2, 2)
	uassert.NoError(t, err, "Expected no error on fetching second page of bids")
	uassert.Equal(t, 1, len(bids), "Expected 1 bid on the second page")

	// Test invalid page
	bids, err = auction.GetPaginatedBids(3, 2)
	uassert.ErrorContains(t, err, "page exceeds total number of bids", "Expected error 'page exceeds total number of bids' for invalid page")

	// Test invalid pagination parameters
	_, err = auction.GetPaginatedBids(0, 2)
	uassert.ErrorContains(t, err, "invalid pagination parameters", "Expected error 'invalid pagination parameters' for invalid pagination")
}

func TestEndAuction(t *testing.T) {
	owner := testutils.TestAddress("owner")
	bidder := testutils.TestAddress("bidder")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("token", 100)

	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice)

	// Simulate the auction running and place a bid
	std.TestSetOrigCaller(bidder)
	auction.Begin = time.Now().Add(-1 * time.Second) // Start the auction
	err := auction.AddBid(bidder, std.NewCoin("token", 150))
	uassert.NoError(t, err, "Unexpected error when placing a bid")

	// Set the auction end time to the past to simulate the auction ending
	auction.End = time.Now().Add(-1 * time.Second)

	// End the auction
	std.TestSetOrigCaller(owner)
	winner, highestBid, err := auction.EndAuction()

	// Ensure no error occurs when ending the auction with bids
	uassert.NoError(t, err, "Expected no error when auction ends with bids")

	// Check that the winner is the correct bidder
	uassert.Equal(t, bidder, winner, "Winner should be the highest bidder")

	// Check that the highest bid is 150 tokens
	uassert.Equal(t, std.NewCoin("token", 150).String(), highestBid.String(), "Highest bid should be 150 tokens")
}
