package auction

import (
	"bytes"
	"std"
	"strconv"
	"time"

	pau "gno.land/p/demo/auction"
	"gno.land/p/demo/mux"
	"gno.land/p/demo/ufmt"
)

// List to store all auctions
var (
	auctionList []*pau.Auction
	currentTime time.Time
	router      = mux.NewRouter()
)

// Map to store deposits for all bidders in the realm
var globalDeposits = make(map[std.Address]int64)

// Initializes the router and handles routes for the auction realm
func init() {
	router.HandleFunc("", renderHomepage)

	router.HandleFunc("/auction/{id}", renderAuctionList)
	// router.HandleFunc("/auction/{id}", renderAuctionDetails)
}

// CreateAuction handles creating a new auction and appends it to the auctionList
func CreateAuction(title, description string, begin int64, end int64, price int64, img string) string {
	owner := std.GetOrigCaller()
	beginTime := time.Unix(begin, 0)
	endTime := time.Unix(end, 0)
	priceAmount := price
	auction := pau.NewAuction(title, owner, description, beginTime, endTime, priceAmount, img)
	auctionList = append(auctionList, auction)
	return "Auction created successfully"
}

// AddBid handles placing a bid on an auction identified by its ID
func AddBid(id int, amount int64) string { // amount en int64
	caller := std.GetOrigCaller()

	// Recupere le montant envoyer qu realm
	// transaction := std.GetOrigSend()
	// amountSend := transaction.AmountOf("ugnot") // montant en ugnot

	// Validate auction ID
	if id >= len(auctionList) || id < 0 {
		panic("Invalid auction ID")
	}
	auction := auctionList[id]

	// Get Banker instance for handling transactions
	// banker := std.GetBanker(std.BankerTypeOrigSend)

	// Check if the bidder already has a deposit in the  realm
	// existingDeposit, exists := globalDeposits[caller]
	// if exists {
	// 	// Calculate additional deposit required
	// 	// Close the auction and return the winner and the highest bid
	// 	additionalAmount := amount - existingDeposit
	// 	if additionalAmount > 0 {
	// 		// Transfer the additional amount from the bidder to the auction realm
	// 		// banker.SendCoins(caller, std.CurrentRealm().Addr(), std.NewCoins(additionalAmount))
	// 		if amountSend != additionalAmount {
	// 			panic("Invalid bid amount vous devez envoyer ")
	// 		}
	// 	}
	// } else {
	// 	globalDeposits[caller] = amount
	// 	// New bidder: deposit the full amount
	// 	if amountSend < globalDeposits[caller] {
	// 		panic("Invalid bid amount")
	// 	}
	// 	// banker.SendCoins(caller, std.CurrentRealm().Addr(), std.NewCoins(amount))
	// 	// globalDeposits[caller] = amount
	// }

	// Place the bid in the auction
	if err := auction.AddBid(caller, amount); err != nil {
		panic(err.Error())
	}

	ufmt.Println("Bid placed successfully")
	return "Bid placed successfully"
}

// // EndAuction handles ending an auction identified by its ID and refund
// func EndAuction(id int) string {
// 	if id >= len(auctionList) || id < 0 {
// 		panic("Invalid auction ID")
// 	}
// 	auction := auctionList[id]

// 	// Call EndAuction to close the auction and get the winner and highest bid
// 	winner, highestBid, err := auction.EndAuction()
// 	if err != nil {
// 		panic(err.Error())
// 	}

// 	// Handle fund transfers using the banker
// 	banker := std.GetBanker(std.BankerTypeRealmSend)
// 	pkgAddr := std.CurrentRealm().Addr()

// 	// Refund all losing bidders
// 	for bidder, deposit := range globalDeposits {
// 		if bidder != winner {
// 			banker.SendCoins(pkgAddr, bidder, std.Coins{{Amount: deposit, Denom: "ugnot"}}) // std.NewCoins(deposit)
// 			// Reset the deposit for the bidder
// 			delete(globalDeposits, bidder)
// 		}
// 	}

// 	// Transfer the highest bid to the auction owner
// 	banker.SendCoins(pkgAddr, auction.Ownable.Owner(), std.Coins{{Amount: highestBid, Denom: "ugnot"}})
// 	// ufmt.Sprintf( "  auc.Price  "\n"))
// 	return "Auction ended successfully"
// }

// EndAuction for testing
func EndAuction(id int) string {
	if id >= len(auctionList) || id < 0 {
		panic("Invalid auction ID")
	}
	auction := auctionList[id]
	if err := auction.EndAuction(); err != nil {
		panic(err.Error())
	}
	return "Auction ended successfully"
}

func GetAuctions() string {
	if len(auctionList) == 0 {
		return "[]"
	}

	node, err := pau.EncodeAuctionList(auctionList)
	if err != nil {
		return "Error encoding auction list: " + err.Error()
	}

	jsonStr, err := pau.ToJSONString(node)
	if err != nil {
		return "Error converting to JSON string: " + err.Error()
	}

	return jsonStr
}

func GetAuctionById(id int) string {
	if id >= len(auctionList) || id < 0 {
		return "Invalid auction ID"
	}

	node, err := pau.EncodeAuction(auctionList[id])
	if err != nil {
		return "Error encoding auction: " + err.Error()
	}

	jsonStr, err := pau.ToJSONString(node)
	if err != nil {
		return "Error converting to JSON string: " + err.Error()
	}

	return jsonStr
}

func Render(path string) string {
	return router.Render(path)
}

// renderCreateAuction renders the auction creation form

// renderAuctionDetails renders the details of a specific auction
// func renderAuctionDetails(res *mux.ResponseWriter, req *mux.Request) {
// 	idStr := req.GetVar("id")
// 	id, err := strconv.Atoi(idStr)
// 	if err != nil || id >= len(auctionList) || id < 0 {
// 		res.Write("Invalid auction ID")
// 		return
// 	}
// 	auc := auctionList[id] // Get the auction by ID

// 	var b bytes.Buffer
// 	b.WriteString("# Auction Details\n")
// }

func renderHomepage(res *mux.ResponseWriter, req *mux.Request) {
	var b bytes.Buffer
	b.WriteString("# Homepage\n\n")
	b.WriteString("## <a href='/r/demo/auction:List'>AuctionList</a>\n\n")

	res.Write(b.String())
}

func renderAuctionList(res *mux.ResponseWriter, req *mux.Request) {
	idStr := req.GetVar("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id >= len(auctionList) || id < 0 {
		res.Write("Invalid auction ID")
		return
	}
	auc := auctionList[id]
	var b bytes.Buffer
	b.WriteString("# Auction List\n\n")

	b.WriteString("\n\n")
	b.WriteString("## " + auc.Title + "\n")
	b.WriteString("### Owner: " + auc.Ownable.Owner().String() + "\n")
	b.WriteString("### Description: " + auc.Description + "\n\n")
	b.WriteString("This auction starts on: " + auc.Begin.String() + " and ends on: " + auc.End.String() + "\n\n")
	b.WriteString(ufmt.Sprintf("### starting Price: %d\n", auc.Price))
	b.WriteString("[View Auction](/auction/" + strconv.Itoa(id) + ")\n")

	res.Write(b.String())
}
