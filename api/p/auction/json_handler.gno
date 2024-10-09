package auction

import (
	"std"
	"time"

	"gno.land/p/demo/json"
	"gno.land/p/demo/ufmt"
)

// EncodeAuction encodes an auction as a JSON Node.
func EncodeAuction(auction *Auction) (*json.Node, error) {
	node := json.ObjectNode("", map[string]*json.Node{
		"title":       json.StringNode("title", auction.Title),
		"description": json.StringNode("description", auction.Description),
		"begin":       json.NumberNode("begin", float64(auction.Begin.Unix())),
		"deadline":    json.NumberNode("deadline", float64(auction.End.Unix())),
		"owner":       json.StringNode("owner", auction.Ownable.Owner().String()),
		"firstPrice":  json.NumberNode("firstPrice", float64(auction.Price)),
		"bids":        json.NumberNode("bids", float64(len(auction.Bids))),
		"img":         json.StringNode("img", auction.Img),
	})

	return node, nil
}

// EncodeAuctionList encodes a list of auctions as a JSON array.
func EncodeAuctionList(auctions []*Auction) (*json.Node, error) {
	var nodes []*json.Node
	for _, auction := range auctions {
		auctionNode, err := EncodeAuction(auction)
		if err != nil {
			return nil, ufmt.Errorf("error encoding auction: %v", err)
		}
		nodes = append(nodes, auctionNode)
	}

	arrayNode := json.ArrayNode("", nodes)
	return arrayNode, nil
}

// DecodeAuction decodes a JSON Node into an Auction struct.
func DecodeAuction(node *json.Node) (*Auction, error) {
	titleNode, err := node.GetKey("title")
	if err != nil {
		return nil, ufmt.Errorf("missing title: %v", err)
	}
	title := titleNode.MustString()

	descriptionNode, err := node.GetKey("description")
	if err != nil {
		return nil, ufmt.Errorf("missing description: %v", err)
	}
	description := descriptionNode.MustString()

	beginNode, err := node.GetKey("begin")
	if err != nil {
		return nil, ufmt.Errorf("missing begin time: %v", err)
	}
	begin := time.Unix(int64(beginNode.MustNumeric()), 0)

	deadlineNode, err := node.GetKey("deadline")
	if err != nil {
		return nil, ufmt.Errorf("missing deadline time: %v", err)
	}
	deadline := time.Unix(int64(deadlineNode.MustNumeric()), 0)

	ownerNode, err := node.GetKey("owner")
	if err != nil {
		return nil, ufmt.Errorf("missing owner: %v", err)
	}
	owner := ownerNode.MustString()

	firstPriceNode, err := node.GetKey("firstPrice")
	if err != nil {
		return nil, ufmt.Errorf("missing firstPrice: %v", err)
	}
	firstPrice := int64(firstPriceNode.MustNumeric())

	imgNode, err := node.GetKey("img")
	if err != nil {
		return nil, ufmt.Errorf("missing img: %v", err)
	}
	img := imgNode.MustString()

	// Crée l'enchère en utilisant les données décodées
	auction := NewAuction(title, std.Address(owner), description, begin, deadline, firstPrice, img)
	return auction, nil
}

// ToJSONString converts a JSON Node into a string representation.
func ToJSONString(node *json.Node) (string, error) {
	jsonBytes, err := json.Marshal(node)
	if err != nil {
		return "", err
	}
	return string(jsonBytes), nil
}

// FromJSONString converts a JSON string into a JSON Node.
func FromJSONString(jsonStr string) (*json.Node, error) {
	node, err := json.Unmarshal([]byte(jsonStr))
	if err != nil {
		return nil, ufmt.Errorf("error parsing JSON: %v", err)
	}
	return node, nil
}
