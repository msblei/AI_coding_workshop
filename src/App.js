import { useState } from 'react';
import './App.css';

const currencyFormatter = new Intl.NumberFormat('de-DE', {
  style: 'currency',
  currency: 'EUR',
});

function App() {
  const price = 500; // Asking price for the painting
  const [bid, setBid] = useState('');
  const [message, setMessage] = useState('');
  const [purchased, setPurchased] = useState(false);

  const handleBidSubmit = (e) => {
    e.preventDefault();
    const amount = parseFloat(bid);

    if (isNaN(amount) || amount <= 0) {
      setMessage('Enter a valid bid amount.');
      return;
    }

    if (amount > price) {
      setPurchased(true);
      setMessage('You bought the picture!');
    } else {
      setMessage('Bid too low. Try a higher amount.');
    }
  };

  const handleReset = () => {
    setBid('');
    setMessage('');
    setPurchased(false);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Art Bidding</h1>
      </header>

      <main className="App-content">
        <div className="art-card">
          <img src="https://picsum.photos/200/300" alt="Random painting" className="art-image" />
          <div className="art-details">
            <div className="price-row">
              <span className="label">Price:</span>
              <span className="price">{currencyFormatter.format(price)}</span>
            </div>

            <form onSubmit={handleBidSubmit} className="bid-form">
              <input
                type="number"
                min="0"
                step="0.01"
                value={bid}
                onChange={(e) => setBid(e.target.value)}
                placeholder="Enter your bid"
                disabled={purchased}
                aria-label="Bid amount"
              />
              <button type="submit" disabled={purchased}>
                Place Bid
              </button>
              <button type="button" className="secondary" onClick={handleReset}>
                Reset
              </button>
            </form>

            {message && (
              <div className={`message ${purchased ? 'success' : 'info'}`}>
                {message}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
