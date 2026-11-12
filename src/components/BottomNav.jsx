import React from 'react';
import { Home, UsersRound, CalendarDays, UserRound } from 'lucide-react';
import { NavLink, useLocation } from 'react-router-dom';

export default function BottomNav() {
  const { pathname } = useLocation();
  const homeContext = pathname === '/' || ['/sport', '/news', '/sponsors', '/shop', '/players', '/cart', '/checkout', '/payment'].some(path => pathname === path || pathname.startsWith(path + '/'));
  const teamContext = ['/my-team', '/performance', '/trials', '/messages'].includes(pathname) || pathname.startsWith('/team-hub/');
  const calendarContext = pathname === '/calendar' || pathname.startsWith('/events/');
  const profileContext = ['/profile', '/orders', '/tickets', '/notifications'].includes(pathname) || pathname === '/admin' || pathname.startsWith('/admin/');
  const items = [
    { to: '/', label: 'Home', Icon: Home, active: homeContext, end: true },
    { to: '/my-team', label: 'My Team', Icon: UsersRound, active: teamContext },
    { to: '/calendar', label: 'Calendar', Icon: CalendarDays, active: calendarContext },
    { to: '/profile', label: 'Me', Icon: UserRound, active: profileContext }
  ];
  return (
    <nav className="bottom-nav" aria-label="Main navigation">
      {items.map(({ to, label, Icon, active, end }) => (
        <NavLink key={to} to={to} end={end} className={active ? 'nav-item active' : 'nav-item'}>
          <Icon size={20} aria-hidden="true"/>
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  );
}