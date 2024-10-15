package auction

import (
	"std"
	"strconv"
	"testing"
	"time"

	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
	"gno.land/p/demo/ufmt"
)

const (
	owner    = testutils.TestAddress("owner")
	begin    = time.Now().Add(1 * time.Hour)
	end      = time.Now().Add(24 * time.Hour)
	minPrice = 100
	deadline = begin.Add(24 * time.Hour)
)

var auction = NewAuction("Test Auction", owner, "This is a test auction", begin, end, minPrice, "url")

func TestToJSONString(t *testing.T) {
	expected := `{"Title":"Test Auction","Description":"This is a test auction","Begin":"` + strconv.Itoa(int(begin.Unix())) + `","End":"` + strconv.Itoa(int(end.Unix())) + `","MinPrice":100,"Deadline":"` + strconv.Itoa(int(deadline.Unix())) + `","Owner":"` + owner.String() + `","URL":"url"}`

	result, err := auction.ToJSONString()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	uassert.Equal(t, result, expected)
}
