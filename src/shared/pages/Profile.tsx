import React from 'react';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ProfileComponents from '../components/Profile/ProfileComponents';
import { useAuth } from '../../context/AuthContext';

interface Profile {
  id: string;
  name: string;
  image: string;
  department: string;
  description: string;
  website?: string;
}

const ProfilePage: React.FC = () => {
  const { auth } = useAuth();
  const navigate = useNavigate();
  const [profile, setProfile] = useState<Profile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Redirect if not authenticated
    if (!auth.isAuthenticated) {
      navigate('/login');
      return;
    }

    const fetchProfile = async () => {
      try {
        setIsLoading(true);
        const response = await fetch(
          `${process.env.REACT_APP_BACKEND_SERVER}/profile`,
          {
            headers: {
              Authorization: `Bearer ${auth.token}`,
            },
          }
        );

        if (!response.ok) {
          throw new Error('Failed to fetch profile');
        }

        const data = await response.json();
        setProfile(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setIsLoading(false);
      }
    };

    fetchProfile();
  }, [auth.isAuthenticated, auth.token, navigate]);

  if (isLoading) {
    return (
      <section className="container-xl center">
        <div>Loading...</div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="container-xl center">
        <div>Error: {error}</div>
      </section>
    );
  }

  if (!profile) {
    return (
      <section className="container-xl center">
        <div>Profile not found</div>
      </section>
    );
  }

  return (
    <section className="container-xl center">
      <ProfileComponents 
        profile={profile} 
        id={profile.id} 
        staff={false} 
      />
    </section>
  );
};

export default ProfilePage;