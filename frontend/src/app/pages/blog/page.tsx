"use client";
import Image from "next/image";
import style from "./style.module.css";
import { useEffect, useState } from "react";
import Link from "next/link";

interface IBlog {
  id: number;
  title: string;
  content: string;
  postedAt: string;
  postedBy: string;
  tags: string[];
}
interface IPage {
  current_page: number;
  total_pages: number;
  total_records: number;
}

export default function Home() {
  const [blog, setBlog] = useState<any>(null);
  const [page, setPage] = useState<number>(1);
  const [lastPage, setLastPage] = useState<number>(1);
  const [search, setSearch] = useState<string>("");
  const [tag, setTag] = useState<any>(null);

  const accessToken = window.localStorage.getItem("access_token");
  const refreshToken = window.localStorage.getItem("refresh_token");

  const myHeaders = new Headers();
  myHeaders.append("Authorization", `Bearer ${accessToken}`);

  const requestOptions: any = {
    method: "GET",
    headers: myHeaders,
    redirect: "follow",
  };
  const requestOptionsPost: any = {
    method: "POST",
    headers: myHeaders,
    redirect: "follow",
  };

  async function generateBlog() {
    const response = await fetch(
      `http://localhost:9090/blogs/get-blog/${page}`,
      requestOptions
    );
    const blog = await response.json();
    setBlog(blog);
    setLastPage(blog.pagination.total_pages);
    setPage(blog.pagination.current_page);
  }

  async function generateTags() {
    const response = await fetch(`http://localhost:9090/blogs/get-tags`,
    requestOptions);
    const tags_json = await response.json();
    setTag(tags_json);
  }

  async function searchBlog() {
    const response = await fetch(
      `http://localhost:9090/blogs/get-blogs/${search}/${page}`,
      requestOptionsPost
    );
    const blog = await response.json();
    setBlog(blog);
    setLastPage(blog.pagination.total_pages);
    setPage(blog.pagination.current_page);
  }

  async function searchBlogTags(searchTag: string) {
    console.log(searchTag, "tagggg");
    const response = await fetch(
      `http://localhost:9090/blogs/get-tags/${searchTag}/${page}`,
      requestOptionsPost
    );
    const blog = await response.json();
    setBlog(blog);
    setLastPage(blog.pagination.total_pages);
    setPage(blog.pagination.current_page);
  }

  function convertDate(value: any) {
    const date = new Date(value);
    const formattedDate = date.toLocaleString();
    return formattedDate;
  }

  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(event.target.value);
  };

  function PageInit({ pagination }: { pagination: number }) {
    let number_paginate = 5;
    if (pagination <= lastPage && pagination >= lastPage - 5) {
      let number_page = lastPage - pagination;
      number_paginate = number_page;
    }
    const pages = Array.from(
      { length: number_paginate },
      (_, index) => index + pagination
    );

    return (
      <>
        {pages.map((page) => (
          <li className="page-item" key={page}>
            <a
              onClick={() => {
                setPage(page);
              }}
              className={`${style["page-link"]} ${
                pagination === page ? style["active"] : ""
              }`}
              href="#"
            >
              {page}
            </a>
          </li>
        ))}

        <li className="page-item">
          <a
            onClick={() => {
              setPage(lastPage);
            }}
            className={`${style["page-link"]} ${
              pagination === lastPage ? style["active"] : ""
            }`}
            href="#"
          >
            {lastPage}
          </a>
        </li>
      </>
    );
  }

  useEffect(() => {
    generateBlog();
  }, [page]);

  useEffect(() => {
    generateTags();
  }, []);

  return (
    <div className="container mx-auto min-h-screen my-3">
      <div className="text-right flex justify-end">
        <input
          onChange={handleChange}
          value={search}
          className="text-black"
          type="text"
          name="name"
        />
        <Image
          src="/search.svg"
          alt="Vercel Logo"
          className={style.pointer}
          width={50}
          height={50}
          onClick={searchBlog}
        />
      </div>

      <div className="flex justify-center flex-wrap gap-4 mt-5 mb-5">
        {tag && (
          <>
            <span>TAGS</span>
            {tag?.data.map((data: any, index: any) => (
              <span
                key={index}
                className={style.spantag}
                onClick={() => {
                  searchBlogTags(data.tag);
                }}
              >
                #{data.tag}
              </span>
            ))}
          </>
        )}
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4">
        {blog?.data.map((data: IBlog, index: any) => (
          <Link
            href={`/pages/blog/${encodeURIComponent(data.id)}`}
            key={data.id}
            className="m-2 col-span-1 block max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100 dark:bg-gray-800 dark:border-gray-700 dark:hover:bg-gray-700"
          >
            <p className="mb-3">Title : {data.title}</p>
            <div>
              <div className="flex justify-start flex-wrap mb-3">
                <span className="mr-2">tag:</span>
                {data.tags.length > 0 ? (
                  data?.tags.map((tag: any, index: number) => (
                    <p key={index} className="mr-2">
                      #{tag}
                    </p>
                  ))
                ) : (
                  <p>-</p>
                )}
              </div>
            </div>
            <div className="">
              <div className="col-span-2">
                <p>postedBy:{data.postedBy}</p>
              </div>
              <div className="col-span-2">
                postedAt: {convertDate(data.postedAt)}
              </div>
            </div>
          </Link>
        ))}
      </div>

      <div className="flex justify-end my-4">
        <nav>
          <ul className={style.pagination}>
            {blog && (
              <>
                <li className="page-item">
                  <div
                    onClick={() =>
                      setPage((prevPage) =>
                        prevPage > 1 ? prevPage - 1 : prevPage
                      )
                    }
                    className={style["page-link"]}
                    aria-label="Previous"
                  >
                    <span aria-hidden="true">&laquo;</span>
                    <span className="sr-only">Previous</span>
                  </div>
                </li>
                <PageInit pagination={page} />
                <li className="page-item">
                  <a
                    onClick={() => setPage(page + 1)}
                    className={style["page-link"]}
                    href="#"
                    aria-label="Next"
                  >
                    <span aria-hidden="true">&raquo;</span>
                    <span className="sr-only">Next</span>
                  </a>
                </li>
              </>
            )}
          </ul>
        </nav>
      </div>
    </div>
  );
}
