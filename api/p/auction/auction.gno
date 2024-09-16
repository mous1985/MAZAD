package auction

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/ownable"
	"gno.land/p/demo/ufmt"
)

// Auction struct
type Auction struct {
	Title       string
	Ownable     *ownable.Ownable
	Description string
	Begin       time.Time
	End         time.Time
	Price       std.Coin
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
	minPrice std.Coin,
) *Auction {
	return &Auction{
		Title:       title,
		Ownable:     ownable.NewWithAddress(owner),
		Description: description,
		Begin:       begin,
		End:         end,
		Price:       minPrice,
		Bids:        []*Bid{},
		State:       "upcoming",
	}
}

func (a *Auction) AddBid(bidder std.Address, amount std.Coin) error {
	currentTime := time.Now()
	if a.State == "closed" {
		ufmt.Println("auction: AddBid: auction is closed")
		return ufmt.Errorf("auction: AddBid: auction is closed")
	}

	if currentTime.Before(a.Begin) {
		return ufmt.Errorf("auction: AddBid: auction has not started yet")
	}
	if currentTime.After(a.End) {
		return ufmt.Errorf("auction: AddBid: auction has already ended")
	}
	if amount.IsLT(a.Price) {
		return ufmt.Errorf("auction: AddBid: bid amount must be higher than the current highest bid")
	}

	bid := &Bid{Bidder: bidder, Amount: uint64(amount.Amount)}
	a.Bids = append(a.Bids, bid)
	a.Price = amount
	std.Emit("BidPlaced", "auction", a.Title, "bidder", bidder.String(), "amount", strconv.FormatInt(amount.Amount, 10))
	return nil
}

// EndAuction ends the auction
func (a *Auction) EndAuction() error {
	// Checks if the caller is the owner
	err := a.Ownable.CallerIsOwner()
	if err != nil {
		return ufmt.Errorf("auction: EndAuction: only the owner can end the auction")
	}

	// Checks if the auction can be closed
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

	// Close auction
	a.State = "closed"
	// highestBid := a.Price
	winner := a.Bids[len(a.Bids)-1].Bidder
	std.Emit("AuctionEnded", "winner", winner.String(), "amount", strconv.FormatInt(a.Price.Amount, 10))
	return nil
}
