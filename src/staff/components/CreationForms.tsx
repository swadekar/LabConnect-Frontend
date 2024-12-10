import React, { useState, useEffect } from "react";
import { useForm, SubmitHandler } from "react-hook-form";
import { useParams } from "react-router";
import { useAuth } from "../../context/AuthContext";
import CheckBox from "./Checkbox";
import Input from "./Input";
import { Locations } from "../../shared/data/locations";

interface CreationFormsProps {
  edit: boolean;
}

interface FormData {
  id: string;
  title: string;
  application_due: string;
  type: string;
  hourlyPay: number;
  credits: string[];
  description: string;
  recommended_experience: string;
  location: string;
  years: string[];
}

const CreationForms: React.FC<CreationFormsProps> = ({ edit }) => {
  const { auth } = useAuth();
  const { postID } = useParams();
  const [loading, setLoading] = useState<string | boolean>(true);
  const [compensationType, setCompensationType] = useState("For Pay");
  const [years, setYears] = useState<string[]>([]);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<FormData>({
    defaultValues: {
      id: "",
      title: "",
      application_due: "",
      type: "For Pay",
      hourlyPay: 0,
      credits: [],
      description: "",
      recommended_experience: "",
      location: "",
      years: [""],
    },
  });

  const fetchYears = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/years`);
      if (response.ok) {
        const data = await response.json();
        setYears(data);
      } else {
        console.error("Failed to fetch years.");
        setLoading("no response");
      }
    } catch (error) {
      console.error("Error fetching years:", error);
      setLoading("no response");
    }
  };

  const fetchEditData = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/editOpportunity/${postID}`, {
        headers: {
          Authorization: `Bearer ${auth.token}`,
        },
      });
      if (response.ok) {
        const data = await response.json();
        reset(data);
        setLoading(false);
      } else {
        console.error("Failed to fetch edit data.");
        setLoading("no response");
      }
    } catch (error) {
      console.error("Error fetching edit data:", error);
      setLoading("no response");
    }
  };

  const submitHandler: SubmitHandler<FormData> = async (data) => {
    const endpoint = edit
      ? `${process.env.REACT_APP_BACKEND_SERVER}/editOpportunity/${postID}`
      : `${process.env.REACT_APP_BACKEND_SERVER}/createOpportunity`;

    const method = edit ? "PUT" : "POST";
    const successMessage = edit ? "Successfully updated" : "Successfully created";

    try {
      const response = await fetch(endpoint, {
        method,
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${auth.token}`,
        },
        body: JSON.stringify(data),
      });
      if (response.ok) {
        alert(successMessage);
        if (!edit) {
          const responseData = await response.json();
          window.location.href = `/opportunity/${responseData.id}`;
        } else {
          window.location.href = `/opportunity/${postID}`;
        }
      } else {
        alert("Failed to save data.");
      }
    } catch (error) {
      console.error("Error submitting data:", error);
    }
  };

  useEffect(() => {
    fetchYears();
    if (edit) {
      fetchEditData();
    } else {
      setLoading(false);
    }
  }, [edit, auth.token, postID, reset]);

  if (loading === "no response") {
    return <h1>No response from the server</h1>;
  }

  if (loading) {
    return <h1>Loading...</h1>;
  }

  return (
    <form onSubmit={handleSubmit(submitHandler)} className="form-container">
      <div className="horizontal-form">
        <Input
          label="Title"
          name="title"
          errors={errors}
          errorMessage="Title must be at least 5 characters"
          formHook={register("title", {
            required: true,
            minLength: 5,
            maxLength: 100,
          })}
          type="text"
          placeHolder="Enter title"
        />
        <Input
          label="Location"
          name="location"
          errors={errors}
          errorMessage="Location is required"
          formHook={register("location", { required: true })}
          type="select"
          options={Locations}
        />
        <Input
          label="Due Date"
          name="application_due"
          errors={errors}
          errorMessage="Due Date is required"
          formHook={register("application_due", { required: true })}
          type="date"
        />
      </div>

      <div className="compensation-box">
        <label>Compensation Type</label>
        {(["For Pay", "For Credit", "Any"] as const).map((type) => (
          <div key={type} className="flex items-center">
            <input
              type="radio"
              value={type}
              {...register("type", { required: true })}
              checked={compensationType === type}
              onChange={() => setCompensationType(type)}
            />
            <label className="pl-2">{type}</label>
          </div>
        ))}
      </div>

      <div className="horizontal-form">
        {compensationType !== "For Credit" && (
          <Input
            label="Hourly Pay"
            name="hourlyPay"
            errors={errors}
            errorMessage="Hourly pay must be at least 0"
            formHook={register("hourlyPay", {
              required: compensationType === "For Pay",
              min: 0,
            })}
            type="number"
          />
        )}

        {compensationType !== "For Pay" && (
          <CheckBox
            label="Credits"
            options={["1", "2", "3", "4"]}
            errors={errors}
            formHook={register("credits", {
              required: compensationType === "For Credit",
            })}
          />
        )}
      </div>

      <div className="horizontal-form">
        <CheckBox
          label="Eligible Class Years"
          options={years}
          errors={errors}
          formHook={register("years", { required: true })}
        />
        <Input
          label="Description"
          name="description"
          errors={errors}
          errorMessage="Description must be at least 10 characters"
          formHook={register("description", {
            required: true,
            minLength: 10,
          })}
          type="textarea"
        />
        <Input
          label="Recommended Experience"
          name="recommended_experience"
          formHook={register("recommended_experience")}
          type="textarea"
        />
      </div>

      <section className="pt-3 pb-5">
        <input type="submit" className="btn btn-primary w-full" />
      </section>
    </form>
  );
};

export default CreationForms;
