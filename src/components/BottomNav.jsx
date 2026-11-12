import React from 'react';
import { Home, UsersRound, CalendarDays, UserRound } from 'lucide-react';
import { NavLink } from 'react-router-dom';

export default function BottomNav() {
  const items = [
    { to: '/', label: 'Home', Icon: Home, end: true },
    { to: '/my-team', label: 'My Team', Icon: UsersRound },
    { to: '/calendar', label: 'Calendar', Icon: CalendarDays },
    { to: '/profile', label: 'Me', Icon: UserRound }
  ];
  return (
    <nav className="bottom-nav" aria-label="Main navigation">
      {items.map(({ to, label, Icon, end }) => (
        <NavLink key={to} to={to} end={end} className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
          <Icon size={20} aria-hidden="true"/>
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  );
}