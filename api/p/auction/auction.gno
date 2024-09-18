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
	Deposits    map[std.Address]std.Coin
	State       string // "upcoming", "ongoing", or "closed"
}

// Bid struct
type Bid struct {
	Bidder std.Address
	Amount uint64
}

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

	// Add the bid and update the price
	bid := &Bid{Bidder: bidder, Amount: uint64(amount.Amount)}
	a.Bids = append(a.Bids, bid)
	a.Price = amount
	return nil
}

// GetPaginatedBids retourne une liste paginée des bids.
func (a *Auction) GetPaginatedBids(page, pageSize int) ([]*Bid, error) {
	if page <= 0 || pageSize <= 0 {
		return nil, ufmt.Errorf("invalid pagination parameters")
	}

	totalBids := len(a.Bids)
	start := (page - 1) * pageSize
	if start >= totalBids {
		return nil, ufmt.Errorf("page exceeds total number of bids")
	}

	end := start + pageSize
	if end > totalBids {
		end = totalBids
	}

	return a.Bids[start:end], nil
}

// EndAuction ends the auction
func (a *Auction) EndAuction() (std.Address, std.Coin, error) {
	if time.Now().Before(a.End) {
		return "", std.Coin{}, ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
	}
	if a.State == "closed" {
		return "", std.Coin{}, ufmt.Errorf("auction: EndAuction: auction is already closed")
	}
	if len(a.Bids) == 0 {
		a.State = "closed"
		return "", std.Coin{}, ufmt.Errorf("auction: EndAuction: auction ended with no bids")
	}

	// Close the auction and return the winner and the highest bid
	a.State = "closed"
	highestBid := a.Price
	winner := a.Bids[len(a.Bids)-1].Bidder
	return winner, highestBid, nil
}
