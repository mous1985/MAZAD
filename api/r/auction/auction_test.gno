package auction

import (
	"std"
	"strings"
	"testing"
	"time"

	"gno.land/p/demo/testutils"
)

func resetCurrentTime() {
	currentTime = time.Time{}
}

// Test the Auction realm functionality with global deposit management
func TestAuctionRealm(t *testing.T) {
	// Simulate the admin creating an auction
	adminAddr := std.Address("admin")
	std.TestSetOrigCaller(adminAddr)

	// Create an auction that starts almost immediately
	begin := time.Now().Add(1 * time.Second).Unix()
	end := time.Now().Add(10 * time.Second).Unix()
	minPrice := std.NewCoin("token", 100)

	// Call the CreateAuction function
	CreateAuction("Test Auction", "A simple test auction", begin, end, minPrice)

	// Check if auction is listed under 'upcoming' section
	std.TestSkipHeights(1) // Move forward by 1 block to allow processing
	updateAuctionStates()

	upcomingPage := Render("upcoming")
	if !strings.Contains(upcomingPage, "Test Auction") {
		t.Errorf("The auction should be listed in the 'upcoming' section")
	}

	// Simulate time passing to move the auction to 'ongoing' state
	std.TestSkipHeights(360) // Fast-forward to the start time of the auction
	updateAuctionStates()

	// Check if auction is now listed under 'ongoing' section
	ongoingPage := Render("ongoing")
	if !strings.Contains(ongoingPage, "Test Auction") {
		t.Errorf("The auction should be listed in the 'ongoing' section")
	}

	// Simulate users placing bids
	user1 := testutils.TestAddress("user1")
	user2 := testutils.TestAddress("user2")

	// Place a bid from user1
	std.TestSetOrigCaller(user1)
	AddBid(0, std.NewCoin("token", 200)) // Bid of 200 tokens

	// Verify that the deposit was recorded in globalDeposits
	if globalDeposits[user1].Amount != 200 {
		t.Errorf("User1's deposit should be 200 tokens")
	}

	// Place a higher bid from user2
	std.TestSetOrigCaller(user2)
	AddBid(0, std.NewCoin("token", 300)) // Bid of 300 tokens

	// Verify that the deposit was recorded in globalDeposits
	if globalDeposits[user2].Amount != 300 {
		t.Errorf("User2's deposit should be 300 tokens")
	}

	// Verify the auction details and the highest bid
	auctionDetails := Render("auction/0")
	if !strings.Contains(auctionDetails, "300 token") {
		t.Errorf("The highest bid should be 300 tokens")
	}

	// Simulate enough time passing for the auction to end
	std.TestSkipHeights(720) // Skip enough blocks to simulate 5 seconds passing (for the auction to end)
	updateAuctionStates()

	// Simulate the admin ending the auction
	std.TestSetOrigCaller(adminAddr)
	EndAuction(0)

	// Verify that the auction has ended
	auctionDetails = Render("auction/0")
	if !strings.Contains(auctionDetails, "Auction ended") {
		t.Errorf("The auction should be closed")
	}

	// Verify that user1 was refunded (as the losing bidder)
	if _, exists := globalDeposits[user1]; exists {
		t.Errorf("User1's deposit should have been refunded and removed from globalDeposits")
	}

	// Verify that user2's deposit was transferred to the auction owner
	if _, exists := globalDeposits[user2]; exists {
		t.Errorf("User2's deposit should have been transferred to the auction owner and removed from globalDeposits")
	}

	// Reset the global state after the test
	resetCurrentTime()
}

// Updates the auction states based on the current time
func updateAuctionStates() {
	now := time.Now()
	for _, auc := range auctionList {
		if auc.State == "upcoming" && now.After(auc.Begin) {
			auc.State = "ongoing"
		} else if auc.State == "ongoing" && now.After(auc.End) {
			auc.State = "closed"
		}
	}
}
