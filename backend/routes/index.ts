import express from 'express';
import jwt from 'jsonwebtoken';
import 'dotenv/config'

interface IUsers{
  id:number;
  name:string;
  refresh:string | null;
}

const router = express.Router();
const token_secret = process.env.ACCESS_TOKEN_SECRET
const token_refresh = process.env.REFRESH_TOKEN_SECRET

if(!token_secret){
  throw new Error("Token empty");
}

if(!token_refresh){
  throw new Error("Refresh empty");
}

const users:IUsers[] = [
  { id: 1, name: "John", refresh: null },
  { id: 2, name: "Tom", refresh: null },
  { id: 3, name: "Chris", refresh: null },
  { id: 4, name: "David", refresh: null },
]

const jwtGenerate = (user:IUsers) => {
  const accessToken = jwt.sign(
    { name: user.name, id: user.id },
    token_secret,
    { expiresIn: "3m", algorithm: "HS256" }
  )


  return accessToken
}

const jwtRefreshTokenGenerate = (user:IUsers) => {
  const refreshToken = jwt.sign(
    { name: user.name, id: user.id },
    token_refresh,
    { expiresIn: "1d", algorithm: "HS256" }
  )

  return refreshToken
}

const jwtRefreshTokenValidate = (req:any, res:any, next:any) => {

  try {
    if (!req.headers["authorization"]) return res.sendStatus(401)
    const token = req.headers["authorization"].replace("Bearer ", "")

    jwt.verify(token, token_refresh, (err:any, decoded:any) => {
      if (err) throw new Error(err)

      req.user = decoded
      req.user.token = token
      delete req.user.exp
      delete req.user.iat
    })
    next()
  } catch (error) {
    return res.sendStatus(403)
  }
}

export const jwtValidate = (req:any, res:any, next:any) => {
  try {
    if (!req.headers["authorization"]) return res.sendStatus(401)
    const token = req.headers["authorization"].replace("Bearer ", "")

    jwt.verify(token, token_secret, (err:any, decoded:any) => {
      if (err) throw new Error(err)
    })
    next()
  } catch (error) {
    return res.sendStatus(403)
  }
}

router.get("/", jwtValidate, (req, res) => {
  res.send("Hello World!")
})

router.post("/auth/login", (req, res) => {
  const { name } = req.body

  const user = users.findIndex((e:any) => e.name === name)

  if (!name || user < 0) {
    return res.send(400)
  }

  const access_token = jwtGenerate(users[user])
  const refresh_token = jwtRefreshTokenGenerate(users[user])

  users[user].refresh = refresh_token

  res.json({
    access_token,
    refresh_token,
  })
})


router.post("/auth/refresh", jwtRefreshTokenValidate, (req:any, res:any) => {
  const user = users.find(
    (e) => e.id === req.user.id && e.name === req.user.name
  )

  const userIndex = users.findIndex((e) => e.refresh === req.user.token)
  if (!user || userIndex < 0) return res.sendStatus(401)

  const access_token = jwtGenerate(user)
  const refresh_token = jwtRefreshTokenGenerate(user)
  users[userIndex].refresh = refresh_token

  return res.json({
    access_token,
    refresh_token,
  })
})


export default router
