package auction

import (
	"std"
	"testing"
	"time"

	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
)

func TestNewAuction(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("ugnot", 100)
	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice, "url")

	uassert.Equal(t, "Test Auction", auction.Title, "Auction title mismatch")
	uassert.Equal(t, owner, auction.Owner.Owner(), "Auction owner mismatch")
	uassert.Equal(t, "This is a test auction", auction.Description, "Auction description mismatch")
	uassert.Equal(t, begin.Unix(), auction.Begin.Unix(), "Auction begin time mismatch")
	uassert.Equal(t, end.Unix(), auction.End.Unix(), "Auction end time mismatch")
	uassert.Equal(t, minPrice.Amount, auction.Price.Amount, "Auction amount price mismatch")
	uassert.Equal(t, minPrice.Denom, auction.Price.Denom, "Auction denom price mismatch")
	uassert.Equal(t, "url", auction.Img, "Image mismatch")
}

func TestAuctionIsActive(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("ugnot", 100)
	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice, "url")

	// Test before auction starts
	err := auction.auctionIsActive()
	uassert.ErrorContains(t, err, "auction has not started yet", "Expected error for auction not started")

	// Simulate auction is active
	auction.Begin = time.Now().Add(-1 * time.Hour)
	auction.End = time.Now().Add(1 * time.Hour)
	err = auction.auctionIsActive()
	uassert.NoError(t, err, "Expected no error for auction active")

	// Simulate auction has ended
	auction.End = time.Now().Add(-1 * time.Hour)
	err = auction.auctionIsActive()
	uassert.ErrorContains(t, err, "auction has already ended", "Expected error for auction ended")
}

func TestValidateBidAmount(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	minPrice := std.NewCoin("ugnot", 100)
	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice, "url")
	bidAmount := std.NewCoin("ugnot", 100)
	// Test valid bid amount
	err := auction.validateBidAmount(bidAmount)
	uassert.NoError(t, err, "Expected no error for valid bid amount")
	bidAmount = std.NewCoin("ugnot", 0)
	// Test invalid bid amount
	err = auction.validateBidAmount(bidAmount)
	uassert.ErrorContains(t, err, "bid amount must be positive", "Expected error for invalid bid amount")
}
