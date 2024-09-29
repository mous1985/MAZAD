"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";

export default function AuctionDetails({ params }: { params: { id: string } }) {
  const { id } = params; // Auction ID from the URL
  const [auction, setAuction] = useState<any>(null);
  const [bidAmount, setBidAmount] = useState("");

  useEffect(() => {
    async function fetchAuctionDetails() {
      try {
        const res = await fetch(`/api/auctions/${id}`);
        const data = await res.json();
        setAuction(data);
      } catch (error) {
        console.error("Error fetching auction details:", error);
      }
    }

    fetchAuctionDetails();
  }, [id]);

  const handleBid = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch(`/api/auctions/${id}/bid`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ amount: bidAmount }),
      });

      if (res.ok) {
        alert("Bid placed successfully");
        setBidAmount("");
      } else {
        alert("Error placing bid");
      }
    } catch (error) {
      console.error("Error placing bid:", error);
    }
  };

  if (!auction) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>{auction.title}</h1>
      <p>{auction.description}</p>
      <p>Current Price: {auction.price} GNOT</p>

      <form onSubmit={handleBid}>
        <input
          type="number"
          value={bidAmount}
          onChange={(e) => setBidAmount(e.target.value)}
          placeholder="Enter bid amount"
        />
        <button type="submit">Place Bid</button>
      </form>
    </div>
  );
}
