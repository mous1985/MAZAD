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
		Ownable:     ownable.NewWithAddress(owner),
		Description: description,
		Begin:       begin,
		End:         end,
		Price:       minPrice,
		Bids:        []*Bid{},
		State:       "upcoming",
	}
}

// AddBid adds a new bid to the auction
func (a *Auction) AddBid(bidder std.Address, amount uint64) error {
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
	if amount <= a.Price {
		return ufmt.Errorf("auction: AddBid: bid amount must be higher than the current highest bid")
	}
	bid := &Bid{Bidder: bidder, Amount: amount}
	a.Bids = append(a.Bids, bid)
	a.Price = amount
	std.Emit("BidPlaced", "auction", a.Title, "bidder", bidder.String(), "amount", strconv.FormatUint(amount, 10))
	return nil
}

func (a *Auction) EndAuction(caller std.Address) error {
	ufmt.Println("Caller Address:", caller)
	ufmt.Println("Owner Address from Ownable:", a.Ownable.Owner())
	ufmt.Println("PrevRealm Address:", std.PrevRealm().Addr())

	// Comparaison explicite des adresses
	if caller != a.Ownable.Owner() {
		ufmt.Println("Direct comparison failed: caller is not the owner")
	} else {
		ufmt.Println("Direct comparison succeeded: caller is the owner")
	}

	// Appel à CallerIsOwner
	err := a.Ownable.CallerIsOwner()
	if err != nil {
		ufmt.Println("CallerIsOwner check failed:", err)
		return ufmt.Errorf("auction: EndAuction: only the owner can end the auction")
	}

	if time.Now().Before(a.End) {
		ufmt.Println("Auction cannot end before the end time")
		return ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
	}

	if a.State == "closed" {
		ufmt.Println("Auction is already closed")
		return ufmt.Errorf("auction: EndAuction: auction is already closed")
	}

	if len(a.Bids) == 0 {
		ufmt.Println("Auction ended with no bids")
		std.Emit("AuctionEndedNoBids", "auction", a.Title)
		return ufmt.Errorf("auction: EndAuction: auction ended with no bids")
	}

	a.State = "closed"
	highestBid := a.Price
	winner := a.Bids[len(a.Bids)-1].Bidder
	ufmt.Println("Auction ended successfully. Winner:", winner, "Amount:", highestBid)
	std.Emit("AuctionEnded", "winner", winner.String(), "amount", strconv.FormatUint(highestBid, 10))

	return nil
}
