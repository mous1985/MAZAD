import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  const { title, description, price } = await req.json();

  // Appel au backend Gno pour enregistrer l'enchère
  const res = await fetch('http://localhost:PORT/mazad/api/create', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      title,
      description,
      price,
    }),
  });

  if (res.ok) {
    const newAuction = await res.json();  // Réponse du backend Gno
    return NextResponse.json(newAuction, { status: 201 });
  } else {
    return NextResponse.json({ error: 'Erreur lors de la création de l\'enchère' }, { status: 500 });
  }
}
