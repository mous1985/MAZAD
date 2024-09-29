"use client";

import { useState } from 'react';
import { callRealmMethod } from '../../utils/gnoClient';

export default function CreateAuction() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [beginTime, setBeginTime] = useState('');
  const [endTime, setEndTime] = useState('');
  const [price, setPrice] = useState('');

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    const beginTimestamp = Math.floor(new Date(beginTime).getTime() / 1000);
    const endTimestamp = Math.floor(new Date(endTime).getTime() / 1000);

    try {
      const result = await callRealmMethod('gno.land/r/mazad/auction', 'CreateAuction', [
        title, description, beginTimestamp, endTimestamp, parseInt(price, 10)
      ]);

      alert('Enchère créée avec succès');
    } catch (error) {
      console.error('Erreur lors de la création de l\'enchère :', error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h1>Créer une nouvelle enchère</h1>
      <input
        type="text"
        placeholder="Titre de l'enchère"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        required
      />
      <input
        type="text"
        placeholder="Description de l'enchère"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        required
      />
      <input
        type="datetime-local"
        placeholder="Date de début"
        value={beginTime}
        onChange={(e) => setBeginTime(e.target.value)}
        required
      />
      <input
        type="datetime-local"
        placeholder="Date de fin"
        value={endTime}
        onChange={(e) => setEndTime(e.target.value)}
        required
      />
      <input
        type="number"
        placeholder="Prix de départ"
        value={price}
        onChange={(e) => setPrice(e.target.value)}
        required
      />
      <button type="submit">Créer l'enchère</button>
    </form>
  );
}
