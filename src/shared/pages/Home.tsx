// Home.tsx
import React from "react";
import { Link } from "react-router-dom";
import logo from "../../images/LabConnect_Logo2.webp";
import SEO from "../components/SEO";
import { NavigationLink } from "./types";

const navigationLinks: NavigationLink[] = [
  { text: "Jobs", path: "/jobs", description: "view currently available research opportunities" },
  { text: "Sign In", path: "/signin", description: "sign in to your account" },
  { text: "Create", path: "/createPost", description: "start posting opportunities" },
  { text: "Profile", path: "/profile", description: "view and edit your current posts" }
];

const Home: React.FC = () => {
  return (
    <main className="flex flex-col items-center py-12">
      <SEO 
        title="Labconnect" 
        description="Connect with research opportunities at LabConnect" 
      />
      
      <div className="w-full max-w-4xl px-4">
        <div className="flex justify-center mb-12">
          <img 
            src={logo} 
            alt="LabConnect" 
            height={289} 
            className="max-w-full"
          />
        </div>

        <div className="text-center">
          <h1 className="text-2xl font-bold mb-6">Welcome to LabConnect!</h1>
          
          <div className="space-y-4 text-lg">
            <p>
              If you are a student, go to the{" "}
              <Link 
                to="/jobs"
                className="text-blue-600 hover:text-blue-900 font-semibold transition-colors"
              >
                Jobs
              </Link>{" "}
              tab to {navigationLinks[0].description}.
            </p>

            <p>
              If you are a professor or staff member, visit these links:
              <ul className="mt-2 space-y-2">
                {navigationLinks.slice(1).map(link => (
                  <li key={link.path}>
                    <Link 
                      to={link.path}
                      className="text-blue-600 hover:text-blue-900 font-semibold transition-colors"
                    >
                      {link.text}
                    </Link>
                    {" "}to {link.description}
                  </li>
                ))}
              </ul>
            </p>
          </div>
        </div>
      </div>
    </main>
  );
};

export default Home;

// types.ts
export interface NavigationLink {
  text: string;
  path: string;
  description: string;
}

// Profile.tsx
import React from "react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import ProfileComponents from "../components/Profile/ProfileComponents";
import { useAuth } from "../../context/AuthContext";

interface Profile {
  id: string;
  name: string;
  image: string;
  department: string;
  description: string;
  website?: string;
}

interface ProfileState {
  data: Profile | null;
  isLoading: boolean;
  error: string | null;
}

const ProfilePage: React.FC = () => {
  const { auth } = useAuth();
  const navigate = useNavigate();
  const [profileState, setProfileState] = useState<ProfileState>({
    data: null,
    isLoading: true,
    error: null
  });

  useEffect(() => {
    if (!auth.isAuthenticated) {
      navigate("/login", { replace: true });
      return;
    }

    const fetchProfile = async () => {
      try {
        const response = await fetch(
          `${process.env.REACT_APP_BACKEND_SERVER}/profile`,
          {
            headers: {
              Authorization: `Bearer ${auth.token}`,
            },
          }
        );

        if (!response.ok) {
          throw new Error("Failed to fetch profile");
        }

        const data = await response.json();
        setProfileState({
          data,
          isLoading: false,
          error: null
        });
      } catch (error) {
        setProfileState({
          data: null,
          isLoading: false,
          error: error instanceof Error ? error.message : "An error occurred"
        });
      }
    };

    fetchProfile();
  }, [auth.isAuthenticated, auth.token, navigate]);

  const renderContent = () => {
    if (profileState.isLoading) {
      return <div className="text-center py-8">Loading...</div>;
    }

    if (profileState.error) {
      return <div className="text-center text-red-600 py-8">{profileState.error}</div>;
    }

    if (!profileState.data) {
      return <div className="text-center py-8">Profile not found</div>;
    }

    return (
      <ProfileComponents 
        profile={profileState.data} 
        id={profileState.data.id} 
        staff={false} 
      />
    );
  };

  return (
    <main className="container mx-auto px-4 py-8">
      {renderContent()}
    </main>
  );
};

export default ProfilePage;