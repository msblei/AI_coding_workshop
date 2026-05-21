import { render, screen } from '@testing-library/react';
import App from './App';

test('renders setup confirmation', () => {
  render(<App />);
  const heading = screen.getByText(/everything works/i);
  expect(heading).toBeInTheDocument();
});
