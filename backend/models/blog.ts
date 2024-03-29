import { CreationOptional, DataTypes, InferAttributes, InferCreationAttributes, Model } from 'sequelize'
import {database} from '../database'

class Blog extends Model<InferAttributes<Blog>, InferCreationAttributes<Blog>> {
  id!: CreationOptional<string>;
  title!: CreationOptional<Text>;
  content!: CreationOptional<Date>;
  postedAt!: CreationOptional<string>;
  postedBy!: CreationOptional<string>;
  tags!: CreationOptional<Array<string>>;
}

Blog.init({
  id: {type:DataTypes.INTEGER,primaryKey:true},
  title: DataTypes.STRING,
  content: DataTypes.TEXT,
  postedAt: DataTypes.DATE,
  postedBy: DataTypes.STRING,
  tags: DataTypes.ARRAY(DataTypes.STRING),

}, { sequelize:database, modelName: 'blog', });

export default Blog

