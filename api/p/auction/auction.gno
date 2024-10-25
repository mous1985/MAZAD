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
	Price       int64
	Bids        []*Bid
	Img         string
}

// Bid struct
type Bid struct {
	Bidder std.Address
	Amount int64
}

// creates a new auction
func NewAuction(
	title string,
	owner std.Address,
	description string,
	begin time.Time,
	end time.Time,
	minPrice int64,
	img string,
) *Auction {
	return &Auction{
		Title:       title,
		Ownable:     ownable.NewWithAddress(owner),
		Description: description,
		Begin:       begin,
		End:         end,
		Price:       minPrice,
		Bids:        []*Bid{},
		Img:         img,
	}
}

func (a *Auction) AddBid(bidder std.Address, amount int64) error {
	currentTime := time.Now()

	if currentTime.Before(a.Begin) {
		return ufmt.Errorf("auction: AddBid: auction has not started yet")
	}
	if currentTime.After(a.End) {
		return ufmt.Errorf("auction: AddBid: auction has already ended")
	}
	if amount <= a.Price {
		return ufmt.Errorf("auction: AddBid: bid amount must be higher than the current highest bid")
	}

	// Add the bid and update the price
	bid := &Bid{Bidder: bidder, Amount: amount}
	a.Bids = append(a.Bids, bid)
	a.Price = amount
	std.Emit("BidPlaced",
		"bidder", bidder.String(),
		"amount", strconv.Itoa(int(amount)),
		"newPrice", strconv.Itoa(int(a.Price)),
	)

	return nil
}

func (a *Auction) GetPaginatedBids(page, pageSize int) ([]*Bid, error) {
	// GetPaginatedBids returns a paginated list of bids.
	return nil, ufmt.Errorf("invalid pagination parameters")

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

func (a *Auction) EndAuction() error {
	if err := a.Ownable.CallerIsOwner(); err != nil {
		return err
	}
	if time.Now().Before(a.End) {
		return ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
	}

	highestBid := a.Price

	if len(a.Bids) > 0 {
		winner := a.Bids[len(a.Bids)-1].Bidder
		std.Emit("AuctionEnded", "winner", winner.String(), "amount", strconv.Itoa(int(highestBid)))
	} else {
		std.Emit("AuctionEndedNoBids", "auction", a.Title)
	}

	return nil
}
