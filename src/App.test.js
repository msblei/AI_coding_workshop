import { render, screen } from '@testing-library/react';
import App from './App';

test('renders workshop greeting', () => {
  render(<App />);
  const heading = screen.getByText(/hello, workshop/i);
  expect(heading).toBeInTheDocument();
});
