import React from 'react';
import JobsNavigation from '../components/JobsNavigation';
import Posts from '../components/Posts';
import SavedJobs from '../components/SavedJobs';
import PageNavigation from '../../shared/components/Navigation/PageNavigation';
import usePageNavigation from '../../shared/hooks/page-navigation-hook';

type PageTypes = 'Search' | 'Saved';

const AVAILABLE_PAGES: PageTypes[] = ['Search', 'Saved'];

const Jobs: React.FC = () => {
  const [pageState, switchPage] = usePageNavigation<PageTypes>(
    AVAILABLE_PAGES,
    'Search'
  );

  const renderContent = () => {
    switch (pageState.activePage) {
      case 'Search':
        return <Posts />;
      case 'Saved':
        return <SavedJobs />;
      default:
        return null;
    }
  };

  return (
    <section className="flex flex-col h-screen gap-3">
      <section className="flex-grow">
        <PageNavigation
          title="Jobs"
          pages={pageState}
          switchPage={switchPage}
        />
        
        <div className="mt-4">
          {renderContent()}
        </div>
      </section>
    </section>
  );
};

export default Jobs;