"use client";
import Image from "next/image";
import style from "./style.module.css";
import { useEffect, useState } from "react";
import { useRouter } from "next/router";
import Link from "next/link";

interface IBlog {
  id: number;
  title: string;
  content: string;
  postedAt: string;
  postedBy: string;
  tag: string;
}

export default function Home() {
  const [blog, setBlog] = useState<any>(null);

  const accessToken = window.localStorage.getItem("access_token");
  const refreshToken = window.localStorage.getItem("refresh_token");
  const myHeaders = new Headers();
  myHeaders.append("Authorization", `Bearer ${accessToken}`);

  const requestOptions: any = {
    method: "POST",
    headers: myHeaders,
    redirect: "follow",
  };


  async function generateBlog() {
    const response = await fetch("http://localhost:9090/blogs/get-tags",
    requestOptions);
    const blog = await response.json();
    setBlog(blog);
  }

  function convertDate(value: any) {
    const date = new Date(value);
    const formattedDate = date.toLocaleString();
    return formattedDate;
  }

  useEffect(() => {
    generateBlog();
  }, []);

  return (
    <div className="container mx-auto min-h-screen">
      <div className="grid grid-cols-2 md:grid-cols-4">
        {blog?.data.map((data: IBlog) => (
          <>
            #{data.tag}
          </>
        ))}
      </div>
    </div>
  );
}
