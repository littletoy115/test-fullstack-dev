import { Sequelize } from 'sequelize';

export const database = new Sequelize('postgres://postgres:password@localhost:6543/example_db_skinx')

export async function connection() {
    try {
        await database.authenticate();
        console.log('Connection has been established successfully.');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
}



export default database