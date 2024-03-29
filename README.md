# test-fullstack-dev
test-fullstack-dev

1.ทำการ Run cmd ใน folder ของ docker `docker-compose up -d`
2.folder ของ backend ให้ทำการติดตั้ง node_module ก่อน `npm install`
3.ทำการ run ตัว backend โดยใช้คำสั่ง npm run dev
4.ทำการ Migrate data sql จากข้อมูล post.json ลงโดยเข้าไปที่ `localhost:9090/blogs/generate-blog`
5.ลองทดสอบ Connect database postgreSQL ว่ามีข้อมูลเข้ามาหรือไม่โดยใช้
HOST:localhost Port:6543 Database:example_db_skinx Username:postgres Password:password
6.ทำการ install node_module ใน folder ของ frontend และทำการ npm run dev เพื่อลองเล่นครับ