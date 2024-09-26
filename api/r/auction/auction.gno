package auction

import (
	"bytes"
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/mux"
	"gno.land/p/demo/ufmt"
)

// List to store all auctions
var (
	auctionList []*Auction
	currentTime time.Time
	router      = mux.NewRouter()
)

// Map to store deposits for all bidders in the realm
var globalDeposits = make(map[std.Address]int64)

// Initializes the router and handles routes for the auction realm
func init() {
	router.HandleFunc("", renderHomepage)
	router.HandleFunc("create/", renderCreateAuction)
	router.HandleFunc("upcoming/", renderUpcomingAuctions)
	router.HandleFunc("ongoing/", renderOngoingAuctions)
	router.HandleFunc("/auction/{id}", renderAuctionDetails)
}

// CreateAuction handles creating a new auction and appends it to the auctionList
func CreateAuction(title, description string, begin, end int64, price int64) string {
	owner := std.GetOrigCaller()
	beginTime := time.Unix(begin, 0)
	endTime := time.Unix(end, 0)
	priceAmount := price
	auction := NewAuction(title, owner, description, beginTime, endTime, priceAmount)
	auctionList = append(auctionList, auction) // Add the auction to the list
	return "Auction created successfully"
}

// AddBid handles placing a bid on an auction identified by its ID
func AddBid(id int, amount int64) string { // amount en int64
	caller := std.GetOrigCaller()

	// Recupere le montant envoyer qu realm
	transaction := std.GetOrigSend()
	amountSend := transaction.AmountOf("ugnot") // montant en ugnot

	// Validate auction ID
	if id >= len(auctionList) || id < 0 {
		panic("Invalid auction ID")
	}
	auction := auctionList[id]

	// Get Banker instance for handling transactions
	// banker := std.GetBanker(std.BankerTypeOrigSend)

	// Check if the bidder already has a deposit in the  realm
	existingDeposit, exists := globalDeposits[caller]
	if exists {
		// Calculate additional deposit required
		// Close the auction and return the winner and the highest bid
		additionalAmount := amount - existingDeposit
		if additionalAmount > 0 {
			// Transfer the additional amount from the bidder to the auction realm
			// banker.SendCoins(caller, std.CurrentRealm().Addr(), std.NewCoins(additionalAmount))
			if amountSend != additionalAmount {
				panic("Invalid bid amount vous devez envoyer ")
			}
		}
	} else {
		globalDeposits[caller] = amount
		// New bidder: deposit the full amount
		if amountSend < globalDeposits[caller] {
			panic("Invalid bid amount")
		}
		// banker.SendCoins(caller, std.CurrentRealm().Addr(), std.NewCoins(amount))
		// globalDeposits[caller] = amount
	}

	// Place the bid in the auction
	if err := auction.AddBid(caller, amount); err != nil {
		panic(err.Error())
	}

	return "Bid placed successfully"
}

// EndAuction handles ending an auction identified by its ID
func EndAuction(id int) string {
	if id >= len(auctionList) || id < 0 {
		panic("Invalid auction ID")
	}
	auction := auctionList[id]

	// Call EndAuction to close the auction and get the winner and highest bid
	winner, highestBid, err := auction.EndAuction()
	if err != nil {
		panic(err.Error())
	}

	// Handle fund transfers using the banker
	banker := std.GetBanker(std.BankerTypeRealmSend)
	pkgAddr := std.CurrentRealm().Addr()

	// Refund all losing bidders
	for bidder, deposit := range globalDeposits {
		if bidder != winner {
			banker.SendCoins(pkgAddr, bidder, std.Coins{{Amount: deposit, Denom: "ugnot"}}) // std.NewCoins(deposit)
			// Reset the deposit for the bidder
			delete(globalDeposits, bidder)
		}
	}

	// Transfer the highest bid to the auction owner
	banker.SendCoins(pkgAddr, auction.Ownable.Owner(), std.Coins{{Amount: highestBid, Denom: "ugnot"}})
	// ufmt.Sprintf( "  auc.Price  "\n"))
	return "Auction ended successfully"
}

// renderHomepage renders the homepage with links to different sections of the auction system
func renderHomepage(res *mux.ResponseWriter, req *mux.Request) {
	var b bytes.Buffer
	b.WriteString("# Homepage\n\n")
	b.WriteString("## <a href='/r/demo/auction:create/'>Create New Auction</a>\n\n")
	b.WriteString("## <a href='/r/demo/auction:upcoming/'>Upcoming Auctions</a>\n\n")
	b.WriteString("## <a href='/r/demo/auction:ongoing/'>Ongoing Auctions</a>\n\n")
	res.Write(b.String()) // Write the homepage to the response
}

func Render(path string) string {
	return router.Render(path)
}

// renderCreateAuction renders the auction creation form
func renderCreateAuction(res *mux.ResponseWriter, req *mux.Request) {
	var b bytes.Buffer
	b.WriteString("<html><body>")

	b.WriteString("# Create New Auction\n\n")
	// b.WriteString("## <a href='/r/demo/auction?help&__func=CreateAuction</a>\n\n")
	b.WriteString("<form action='/create' method='post'>\n")
	b.WriteString("Title: <input type='text' name='title'><br>\n")
	// b.WriteString("Description: <input type='text' name='description'><br>\n")
	// b.WriteString("Begin: <input type='datetime-local' name='begin'><br>\n")
	// b.WriteString("End: <input type='datetime-local' name='end'><br>\n")
	// b.WriteString("Starting Price: <input type='number' name='price'><br>\n")
	// b.WriteString("<input type='submit' value='Create Auction'>\n")
	// b.WriteString("</form>\n")
	// b.WriteString("</body></html>")
	res.Write(b.String()) // Write the form to the response
}

// renderUpcomingAuctions renders the list of upcoming auctions
func renderUpcomingAuctions(res *mux.ResponseWriter, req *mux.Request) {
	var b bytes.Buffer
	b.WriteString("<h1>Upcoming Auctions</h1>\n")

	// Iterate over the list of auctions to find those with state 'upcoming'
	for i, auc := range auctionList {
		if auc.State == "upcoming" {
			b.WriteString("\n\n")
			b.WriteString("## " + auc.Title + "\n")
			b.WriteString("### Owner: " + auc.Ownable.Owner().String() + "\n")
			b.WriteString("### Description: " + auc.Description + "\n\n")
			b.WriteString("This auction starts on: " + auc.Begin.String() + " and ends on: " + auc.End.String() + "\n\n")
			b.WriteString(ufmt.Sprintf("### starting Price: %d\n", auc.Price))
			b.WriteString("[View Auction](/auction/" + strconv.Itoa(i) + ")\n")
		}
	}
	res.Write(b.String())
}

// renderOngoingAuctions renders the list of ongoing auctions
func renderOngoingAuctions(res *mux.ResponseWriter, req *mux.Request) {
	var b bytes.Buffer
	b.WriteString("# Ongoing Auctions\n")

	// Iterate over the list of auctions to find those with state 'ongoing'
	for i, auc := range auctionList {
		if auc.State == "ongoing" {
			b.WriteString("## " + auc.Title + "\n")
			b.WriteString("### Owner: " + auc.Ownable.Owner().String() + "\n")
			b.WriteString("### Description: " + auc.Description + "\n\n")
			b.WriteString("This auction started on: " + auc.Begin.String() + " and ends on: " + auc.End.String() + "\n\n")
			b.WriteString(ufmt.Sprintf("### Current Price: %d\n", auc.Price))
			b.WriteString("[View Auction](/auction/" + strconv.Itoa(i) + ")\n")
		}
	}
	res.Write(b.String()) // Write the ongoing auctions to the response
}

// renderAuctionDetails renders the details of a specific auction
func renderAuctionDetails(res *mux.ResponseWriter, req *mux.Request) {
	idStr := req.GetVar("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id >= len(auctionList) || id < 0 {
		res.Write("Invalid auction ID")
		return
	}
	auc := auctionList[id] // Get the auction by ID

	var b bytes.Buffer
	b.WriteString("# Auction Details\n")
	b.WriteString("## " + auc.Title + "\n")
	b.WriteString("### Owner: " + auc.Ownable.Owner().String() + "\n")
	b.WriteString("### Description: " + auc.Description + "\n\n")
	b.WriteString("This auction starts on: " + auc.Begin.String() + " and ends on: " + auc.End.String() + "\n\n")
	b.WriteString(ufmt.Sprintf("### Current Price: %d\n", auc.Price))

	// If the auction is ongoing, provide a form to place a bid
	if auc.State == "ongoing" {
		b.WriteString("<form action='/bid' method='post'>\n")
		b.WriteString("Amount: <input type='number' name='amount'><br>\n")
		b.WriteString("<input type='hidden' name='id' value='" + strconv.Itoa(id) + "'>\n")
		b.WriteString("<input type='submit' value='Place Bid'>\n")
		b.WriteString("</form>\n")
	}

	res.Write(b.String())
}
