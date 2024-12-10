import React from 'react';
import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import JobDetails from '../components/JobDetails';

interface JobPost {
  title: string;
  description: string;
  author: string;
  id: string;
  authorProfile: string;
  department: string;
  aboutSection: Array<{
    title: string;
    description: string;
  }>;
}

interface FetchResponse {
  data: JobPost;
}

const IndividualPost: React.FC = () => {
  const { postID } = useParams<{ postID: string }>();
  const [state, setState] = useState<{
    isLoading: boolean;
    error: string | null;
    data: JobPost | null;
  }>({
    isLoading: true,
    error: null,
    data: null,
  });

  useEffect(() => {
    const fetchOpportunity = async () => {
      try {
        setState(prev => ({ ...prev, isLoading: true, error: null }));
        
        const baseURL = process.env.REACT_APP_BACKEND_SERVER;
        const response = await fetch(`${baseURL}/getOpportunity/${postID}`);

        if (!response.ok) {
          throw new Error('Failed to fetch opportunity details');
        }

        const result: FetchResponse = await response.json();
        setState(prev => ({
          ...prev,
          data: result.data,
          isLoading: false,
        }));
      } catch (error) {
        setState(prev => ({
          ...prev,
          error: error instanceof Error ? error.message : 'An error occurred',
          isLoading: false,
        }));
      }
    };

    fetchOpportunity();
  }, [postID]);

  if (state.isLoading) {
    return (
      <div className="flex justify-center items-center min-h-[200px]">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  if (state.error || !state.data) {
    return (
      <div className="flex justify-center items-center min-h-[200px]">
        <p className="text-red-500">
          {state.error || 'No post found'}
        </p>
      </div>
    );
  }

  return <JobDetails {...state.data} />;
};

export default IndividualPost;