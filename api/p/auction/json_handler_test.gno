package auction

import (
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/json"
	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
	"gno.land/p/demo/ufmt"
)

func TestEncodeAuction(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	auction := NewAuction("Test Auction", owner, "This is a test auction", begin, end, 100, "url")

	node, err := EncodeAuction(auction)
	uassert.NoError(t, err, "Unexpected error encoding auction")

	jsonStr, err := ToJSONString(node)
	uassert.NoError(t, err, "Unexpected error converting JSON node to string")
	ufmt.Println(jsonStr)

	expected := `{"title":"Test Auction","description":"This is a test auction","begin":` + strconv.Itoa(int(begin.Unix())) + `,"deadline":` + strconv.Itoa(int(end.Unix())) + `,"owner":"` + owner.String() + `","firstPrice":100,"bids":0,"img":"url"}`
	uassert.Equal(t, expected, jsonStr, "Encoded auction JSON mismatch")
}

func TestEncodeAuctionList(t *testing.T) {
	owner := testutils.TestAddress("owner")
	begin := time.Now().Add(1 * time.Hour)
	end := time.Now().Add(24 * time.Hour)
	auction1 := NewAuction("Test Auction 1", owner, "This is a test auction 1", begin, end, 100, "url1")
	auction2 := NewAuction("Test Auction 2", owner, "This is a test auction 2", begin, end, 200, "url2")

	auctions := []*Auction{auction1, auction2}
	node, err := EncodeAuctionList(auctions)
	uassert.NoError(t, err, "Unexpected error encoding auction list")

	jsonStr, err := ToJSONString(node)
	uassert.NoError(t, err, "Unexpected error converting JSON node to string")

	expected := `[{"title":"Test Auction 1","description":"This is a test auction 1","begin":` + strconv.Itoa(int(begin.Unix())) + `,"deadline":` + strconv.Itoa(int(end.Unix())) + `,"owner":"` + owner.String() + `","firstPrice":100,"bids":0,"img":"url1"},{"title":"Test Auction 2","description":"This is a test auction 2","begin":` + strconv.Itoa(int(begin.Unix())) + `,"deadline":` + strconv.Itoa(int(end.Unix())) + `,"owner":"` + owner.String() + `","firstPrice":200,"bids":0,"img":"url2"}]`
	uassert.Equal(t, expected, jsonStr, "Encoded auction list JSON mismatch")
}

func TestDecodeAuction(t *testing.T) {
	jsonStr := `{"title":"Test Auction","description":"This is a test auction","begin":` + strconv.Itoa(int(time.Now().Add(1*time.Hour).Unix())) + `,"deadline":` + strconv.Itoa(int(time.Now().Add(24*time.Hour).Unix())) + `,"owner":"owner","firstPrice":100,"bids":0,"img":"url"}`
	node, err := FromJSONString(jsonStr)
	uassert.NoError(t, err, "Unexpected error parsing JSON string")

	auction, err := DecodeAuction(node)
	uassert.NoError(t, err, "Unexpected error decoding auction")

	uassert.Equal(t, "Test Auction", auction.Title, "Auction title mismatch")
	uassert.Equal(t, "This is a test auction", auction.Description, "Auction description mismatch")
	uassert.Equal(t, int64(100), auction.Price, "Auction price mismatch")
	uassert.Equal(t, "url", auction.Img, "Auction image URL mismatch")
}

func TestToJSONString(t *testing.T) {
	node := json.ObjectNode("", map[string]*json.Node{
		"key": json.StringNode("key", "value"),
	})

	jsonStr, err := ToJSONString(node)
	uassert.NoError(t, err, "Unexpected error converting JSON node to string")

	expected := `{"key":"value"}`
	uassert.Equal(t, expected, jsonStr, "JSON string mismatch")
}

func TestFromJSONString(t *testing.T) {
	jsonStr := `{"key":"value"}`
	node, err := FromJSONString(jsonStr)
	uassert.NoError(t, err, "Unexpected error parsing JSON string")

	valueNode, err := node.GetKey("key")
	uassert.NoError(t, err, "Unexpected error getting key from JSON node")
	uassert.Equal(t, "value", valueNode.MustString(), "JSON node value mismatch")
}
