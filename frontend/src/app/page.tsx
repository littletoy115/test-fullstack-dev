"use client";
import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();
  async function generateBlog() {
    
    const raw = JSON.stringify({
      name: "John",
      password: "1234",
    });

    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: raw,
    };
    const response = await fetch(
      "http://localhost:9090/auth/login",
      requestOptions
    );
    const data = await response.json();
    if (data) {
      console.log("Success");
      localStorage.setItem("access_token", data.access_token);
      localStorage.setItem("refresh_token", data.refresh_token);
      router.push("/pages/blog");
    }
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-center font-mono text-sm lg:flex">
        <div className="marker:text-sky-400 list-disc pl-5 space-y-3 text-slate-400 text-center">
          <label>Username</label>
          &nbsp;
          <input type="text" className="mb-3"></input>
          <br></br>
          <label>Password</label>
          &nbsp;
          <input type="text"></input>
          <br></br>
          <button className="btn btn-color" onClick={generateBlog}>
            Login
          </button>
        </div>
      </div>
    </main>
  );
}
