import React from "react";
import { Link } from "react-router-dom";
import logo from "../../../images/LabConnect_Logo.webp";

export default function StickyFooter(authenticated) {

  const routes = authenticated.authenticated[1]
    ? [
      { name: "Jobs", href: "/jobs", current: true },
      { name: "Create", href: "/create", current: false },
      { name: "Staff", href: "/staff", current: false },
      { name: "Profile", href: "/profile", current: false },
      { name: "Sign Out", href: "/signout", current: false },
    ]
    : [{ name: "Sign In", href: "/signin", current: false }];

  return (
    <section className="stickyfooter-general">
      <h1 className="stickyfooter-header">
        Made by{" "}
        <Link to="https://new.rcos.io" className="no-underline text-red-600 hover:text-red-800 focus:text-red-800">
          RCOS
        </Link>
      </h1>
      <div className="stickyfooter-info mt-5">
        <div className="pb-3">
          <img src={logo} alt="LabConnect" width="160" height="160 / (319/289)" />
        </div>

        <div className="w-40">
          <div>
            <b>Contact Us</b>
            <p className="text-base">
              <Link
                to="https://discord.gg/tsaxCKjYHT"
                className="grey-link hover:text-neutral-950 focus:text-neutral-950"
              >
                Discord
              </Link>
              <br />
              <Link
                to="https://github.com/LabConnect-RCOS"
                className="grey-link hover:text-neutral-950 focus:text-neutral-950"
              >
                GitHub
              </Link>
              <br />
            </p>
          </div>
        </div>
        <div>
          <b>Resources</b>
          <br />
          {routes.map((item) => (
            <React.Fragment key={item.name}>
              <Link
                to={item.href}
                className="grey-link hover:text-neutral-950 focus:text-neutral-950"
                aria-current={item.current}
              >
                {item.name}
              </Link>
              <br />
            </React.Fragment>
          ))}
        </div>
      </div >
    </section >
  );
}
