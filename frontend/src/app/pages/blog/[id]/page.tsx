"use client";
import { METHODS } from "http";
import { init } from "next/dist/compiled/webpack/webpack";
import { useEffect, useState } from "react";
interface IPageProps {
  params: { id: string };
  searchParams: Record<string, string | undefined>;
}
interface IBlog {
  id: string;
  title: string;
  content: string;
  postedAt: string;
  postedBy: string;
}
export default function Page(props: IPageProps) {
  const [BlogState, setBlog] = useState<IBlog>();

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
    const response = await fetch(
      `http://localhost:9090/blogs/get-blog/${props.params.id}`,
      requestOptions
    );
    const blog = await response.json();
    setBlog(blog[0]);
  }

  function createMarkup(data: any) {
    return { __html: data };
  }

  function HtmlsetElement(html: any) {
    return <div dangerouslySetInnerHTML={createMarkup(html.data)} />;
  }

  useEffect(() => {
    generateBlog();
  }, []);

  return (
    <>
      <div className="container mx-auto min-h-screen">
        {BlogState && <p className="text-center">{BlogState.title}</p>}
        <div className="mb-5">
          <HtmlsetElement data={BlogState?.content} />
        </div>
        <div className="text-right">
          {BlogState && <p>{BlogState.postedBy}</p>}
          {/* {BlogState && <p>{BlogState.postedAt}</p>} */}
        </div>
      </div>
    </>
  );
}
