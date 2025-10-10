import { Outlet } from 'react-router';
import { Account } from './components/account-info';

export function MainLayout() {
  return <div>
    <div>
      <Account />
    </div>
    <Outlet />
  </div>
}
