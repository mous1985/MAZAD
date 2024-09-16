package auction

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/ufmt"
)

// Auction struct
type Auction struct {
	Title       string
	Owner       std.Address
	Description string
	Begin       time.Time
	End         time.Time
	Price       uint64
	Bids        []*Bid
	State       string // "upcoming", "ongoing", or "closed"
}

// Bid struct
type Bid struct {
	Bidder std.Address
	Amount uint64
}

var auctionList []*Auction

// NewAuction creates a new auction
func NewAuction(
	title string,
	owner std.Address,
	description string,
	begin time.Time,
	end time.Time,
	minPrice uint64,
) *Auction {
	return &Auction{
		Title:       title,
		Description: description,
		Owner:       owner,
		Begin:       begin,
		End:         end,
		Price:       minPrice,
		Bids:        []*Bid{},
		State:       "upcoming",
	}
}

// AddBid adds a new bid to the auction
func (a *Auction) AddBid(bidder std.Address, amount uint64) error {
	currentTime := time.Now() // Ajouter un suivi du temps actuel
	if a.State == "closed" {
		ufmt.Println("auction: AddBid: auction is closed")
		return ufmt.Errorf("auction: AddBid: auction is closed")
	}
	// Comparaison plus précise avec Before et After
	if currentTime.Before(a.Begin) {
		ufmt.Println("auction: AddBid: auction has not started yet")
		return ufmt.Errorf("auction: AddBid: auction has not started yet")
	}
	if currentTime.After(a.End) {
		ufmt.Println("auction: AddBid: auction has already ended")
		return ufmt.Errorf("auction: AddBid: auction has already ended")
	}
	if amount <= a.Price {
		ufmt.Println("auction: AddBid: bid amount must be higher than the current highest bid")
		return ufmt.Errorf("auction: AddBid: bid amount must be higher than the current highest bid")
	}
	bid := &Bid{Bidder: bidder, Amount: amount}
	a.Bids = append(a.Bids, bid)
	a.Price = amount
	std.Emit("BidPlaced", "auction", a.Title, "bidder", bidder.String(), "amount", strconv.FormatUint(amount, 10))
	return nil
}

// IsOwnedBy checks if the given address is the owner of the auction
func (a *Auction) IsOwnedBy(address std.Address) bool {
	return a.Owner == address
}

// EndAuction ends the auction
func (a *Auction) EndAuction(caller std.Address) error {
	if caller != a.Owner {
		return ufmt.Errorf("auction: EndAuction: only the owner can end the auction")
	}
	if time.Now().Before(a.End) {
		return ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
	}
	if a.State == "closed" {
		return ufmt.Errorf("auction: EndAuction: auction is already closed")
	}
	if len(a.Bids) == 0 {
		std.Emit("AuctionEndedNoBids", "auction", a.Title)
		return ufmt.Errorf("auction: EndAuction: auction ended with no bids")
	}
	a.State = "closed"
	highestBid := a.Price
	winner := a.Bids[len(a.Bids)-1].Bidder
	std.Emit("AuctionEnded", "winner", winner.String(), "amount", strconv.FormatUint(highestBid, 10))
	return nil
}
