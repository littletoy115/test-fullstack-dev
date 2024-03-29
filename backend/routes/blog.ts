import express from 'express';
import fs from 'fs';
import {database} from '../database'
import Blog from '../models/blog'
import {jwtValidate} from './index'
import { Sequelize, Op } from 'sequelize'


const router = express.Router();

router.use(jwtValidate);

//BLOGS
router.get('/get-blog/:page', async function (req, res) {
    let limit = 100;
    let page = req.params.page || 1;
    let cvtPage = parseInt(page as string);
    const offset = (cvtPage - 1) * limit; 
    
    const totalCount = await Blog.count();
    const totalPages = Math.ceil(totalCount / limit);

    const users = await Blog.findAll({
        order: [['id', 'ASC']],
        limit: 100,
         offset: offset,
    });
    return res.json({
        data: users,
        pagination: {
            total_pages: totalPages,
            current_page: cvtPage,
            total_records: totalCount
        }
    });
});


router.post('/get-blogs/:search/:page', async function (req, res) {
    let limit = 100;
    let page = req.params.page || 1;
    let cvtPage = parseInt(page as string);
    let searchTag = req.params.search
    const offset = (cvtPage - 1) * limit; 

    const users = await Blog.findAll<Blog>({
        order: [['id', 'ASC']],
        limit: limit,
        offset: offset,
        where: {
            title: {
              [Op.substring]: Sequelize.literal(searchTag)
            }
        }
    });
    const totalCount = users.length
    const totalPages = Math.ceil(totalCount / limit);
    return res.json({
        data: users,
        pagination: {
            total_pages: totalPages,
            current_page: cvtPage,
            total_records: totalCount
        }
    });
});

//TAGS 
router.get('/get-tags', async function (req, res) {
    const users = await Blog.findAll({
        attributes: [
            [database.literal('DISTINCT UNNEST("tags")'), 'tag']
        ],
        order: [['tag', 'ASC']]
    });
    return res.json({data:users});
});

router.post('/get-tags/:tags/:page', async function (req, res) {
    let limit = 100;
    let page = req.params.page || 1;
    let cvtPage = parseInt(page as string);
    let searchTag = req.params.tags
    const offset = (cvtPage - 1) * limit; 
    const users = await Blog.findAll({
        order: [['id', 'ASC']],
        limit: limit,
        offset: offset,
        where: {
            tags: {
              [Op.contains]: [searchTag]
            }
        }
    });
    const totalCount = users.length
    const totalPages = Math.ceil(totalCount / limit);
    return res.json({
        data: users,
        pagination: {
            total_pages: totalPages,
            current_page: cvtPage,
            total_records: totalCount
        }
    });
});


router.post('/get-blog/:id', async function (req, res) {
    const users = await Blog.findAll({
        where: {
            id: req.params.id
        },
        order: [['id', 'ASC']]
    });
    return res.json(users);
});



router.get('/generate-blog', function (req, res) {
    const jsonData = fs.readFileSync('./models/post.json', 'utf8');
    const data = JSON.parse(jsonData);

    async function seedDatabase() {
        try {
            await database.sync({ force: true });
            await Blog.bulkCreate(data);
            console.log('ข้อมูลถูกเพิ่มลงในฐานข้อมูลเรียบร้อยแล้ว');
            res.send('respond with a resource');
        } catch (error) {
            console.error('เกิดข้อผิดพลาดในการเพิ่มข้อมูล:', error);
        } finally {
            await database.close();
        }
    }

    seedDatabase();
});

export default router
