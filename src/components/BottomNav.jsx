import React from 'react';
import { Home, Trophy, UsersRound, ShoppingBag, UserRound } from 'lucide-react';
import { NavLink, useLocation } from 'react-router-dom';

export default function BottomNav() {
  const { pathname } = useLocation();
  const homeContext = pathname === '/';
  const sportContext = ['/sport', '/news', '/sponsors', '/players', '/calendar'].some(path => pathname === path || pathname.startsWith(path + '/')) || pathname.startsWith('/events/');
  const teamContext = ['/my-team', '/performance', '/trials', '/messages'].includes(pathname) || pathname.startsWith('/team-hub/');
  const shopContext = ['/shop', '/cart', '/checkout', '/payment', '/orders'].some(path => pathname === path || pathname.startsWith(path + '/'));
  const profileContext = ['/profile', '/tickets', '/notifications'].includes(pathname) || pathname === '/admin' || pathname.startsWith('/admin/');
  const items = [
    { to: '/', label: 'Home', Icon: Home, active: homeContext, end: true },
    { to: '/sport', label: 'Sport', Icon: Trophy, active: sportContext },
    { to: '/my-team', label: 'My Team', Icon: UsersRound, active: teamContext },
    { to: '/shop', label: 'Shop', Icon: ShoppingBag, active: shopContext },
    { to: '/profile', label: 'Profile', Icon: UserRound, active: profileContext }
  ];
  return (
    <nav className="bottom-nav" aria-label="Main navigation">
      {items.map(({ to, label, Icon, active, end }) => (
        <NavLink key={to} to={to} end={end} className={active ? 'nav-item active' : 'nav-item'} aria-current={active ? 'page' : undefined}>
          <Icon size={20} aria-hidden="true"/>
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  );
}