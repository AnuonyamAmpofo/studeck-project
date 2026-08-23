const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const env = require('../config/env');

const signAccessToken = (userId) =>
  jwt.sign({ sub: userId }, env.jwt.accessSecret, { expiresIn: env.jwt.accessExpiresIn });

const signRefreshToken = (userId) =>
  jwt.sign({ sub: userId }, env.jwt.refreshSecret, { expiresIn: env.jwt.refreshExpiresIn });

const verifyAccessToken = (token) => jwt.verify(token, env.jwt.accessSecret);
const verifyRefreshToken = (token) => jwt.verify(token, env.jwt.refreshSecret);

// Refresh tokens are stored hashed (sha256) so a leaked DB row can't be replayed as-is.
const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashToken,
};
