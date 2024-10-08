package auction

import (
	"std"
	"strconv"
	"strings"
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
	// Deposits    map[std.Address]int64
	// State string // "upcoming", "ongoing", or "closed"
}

// Bid struct
type Bid struct {
	Bidder std.Address
	Amount int64
}

// NewAuction creates a new auction
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
		// State:       "upcoming",
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
// func (a *Auction) EndAuction() (std.Address, int64, error) {
// 	if time.Now().Before(a.End) {
// 		return "", 0, ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
// 	}
// 	if time.Now().After(a.End) {
// 		return "", 0, ufmt.Errorf("auction: EndAuction: auction is already closed")
// 	}
// 	if len(a.Bids) == 0 {
// 		return "", 0, ufmt.Errorf("auction: EndAuction: auction ended with no bids")
// 	}

// 	// Close the auction and return the winner and the highest bid

//		highestBid := a.Price
//		winner := a.Bids[len(a.Bids)-1].Bidder
//		return winner, highestBid, nil
//	}
func (a *Auction) EndAuction() error {
	if err := a.Ownable.CallerIsOwner(); err != nil {
		return err
	}
	if time.Now().Before(a.End) {
		return ufmt.Errorf("auction: EndAuction: auction cannot end before the end time")
	}
	if time.Now().After(a.End) {
		return ufmt.Errorf("auction: EndAuction: auction is already closed")
	}
	if len(a.Bids) == 0 {
		std.Emit("AuctionEndedNoBids", "auction", a.Title)
		return ufmt.Errorf("auction: EndAuction: auction ended with no bids")
	}

	highestBid := a.Price
	winner := a.Bids[len(a.Bids)-1].Bidder
	std.Emit("AuctionEnded", "winner", winner.String(), "amount", strconv.Itoa(int(highestBid)))
	return nil
}

func AuctionsToJSONString(auctions []*Auction) string {
	var sb strings.Builder
	sb.WriteString("[")

	for i, auction := range auctions {
		if i > 0 {
			sb.WriteString(",")
		}

		sb.WriteString(AuctionToJSONString(auction))
	}
	sb.WriteString("]")

	return sb.String()
}

// AuctionToJSONString returns a Auction formatted as a JSON string
func AuctionToJSONString(auction *Auction) string {
	var sb strings.Builder

	sb.WriteString("{")
	sb.WriteString(`"title":"` + escapeString(auction.Title) + `",`)
	sb.WriteString(`"description":"` + escapeString(auction.Description) + `",`)
	sb.WriteString(`"begin":"` + strconv.Itoa(int(auction.Begin.Unix())) + `",`)
	sb.WriteString(`"deadline":"` + strconv.Itoa(int(auction.End.Unix())) + `",`)
	sb.WriteString(`"owner":"` + auction.Ownable.Owner().String() + `",`)
	sb.WriteString(`"firstPrice":"` + strconv.Itoa(int(auction.Price)) + `",`)
	sb.WriteString(`"bids":` + strconv.Itoa(len(auction.Bids)) + `,`)
	sb.WriteString(`"img":"` + escapeString(auction.Img) + `"`)
	sb.WriteString("}")

	return sb.String()
}

func ErrorToJSONString(err error) string {
	if err == nil {
		return `{"error": null}`
	}

	var sb strings.Builder

	sb.WriteString("{")
	sb.WriteString(`"error": "` + escapeString(err.Error()) + `"`)
	sb.WriteString("}")

	return sb.String()
}

// escapeString escapes quotes in a string for JSON compatibility.
func escapeString(s string) string {
	return strings.ReplaceAll(s, `"`, `\"`)
}
