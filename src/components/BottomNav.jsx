import React from 'react';
import { Home, ShoppingBag, Trophy, UserRound } from 'lucide-react';
import { NavLink } from 'react-router-dom';
export default function BottomNav() {
  const items = [{ to: '/', label: 'Home', Icon: Home }, { to: '/shop', label: 'Shop', Icon: ShoppingBag }, { to: '/sport', label: 'Sport', Icon: Trophy }, { to: '/profile', label: 'Profile', Icon: UserRound }];
  return <nav className="bottom-nav">{items.map(({ to, label, Icon }) => <NavLink key={to} to={to} end={to === '/'} className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}><Icon size={20}/><span>{label}</span></NavLink>)}</nav>;
}