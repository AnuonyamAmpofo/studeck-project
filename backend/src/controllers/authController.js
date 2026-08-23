const jwt = require('jsonwebtoken');
const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const { hashPassword, comparePassword } = require('../utils/password');
const { signAccessToken, signRefreshToken, verifyRefreshToken, hashToken } = require('../utils/jwt');
const userModel = require('../models/userModel');
const refreshTokenModel = require('../models/refreshTokenModel');

const REFRESH_COOKIE_MAX_AGE_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

async function issueTokens(res, userId) {
  const accessToken = signAccessToken(userId);
  const refreshToken = signRefreshToken(userId);
  const { exp } = jwt.decode(refreshToken);

  await refreshTokenModel.store({
    userId,
    tokenHash: hashToken(refreshToken),
    expiresAt: new Date(exp * 1000),
  });

  res.cookie('refreshToken', refreshToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: REFRESH_COOKIE_MAX_AGE_MS,
  });

  return accessToken;
}

const register = asyncHandler(async (req, res) => {
  const { email, password, fullName } = req.body;

  const existing = await userModel.findByEmail(email);
  if (existing) throw new ApiError(409, 'An account with this email already exists');

  const passwordHash = await hashPassword(password);
  const user = await userModel.createUser({ email, passwordHash, fullName });

  const accessToken = await issueTokens(res, user.id);
  res.status(201).json({ user, accessToken });
});

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await userModel.findByEmail(email);
  if (!user) throw new ApiError(401, 'Invalid email or password');

  const valid = await comparePassword(password, user.password_hash);
  if (!valid) throw new ApiError(401, 'Invalid email or password');

  const accessToken = await issueTokens(res, user.id);
  delete user.password_hash;
  res.json({ user, accessToken });
});

const refresh = asyncHandler(async (req, res) => {
  const token = req.cookies?.refreshToken;
  if (!token) throw new ApiError(401, 'Missing refresh token');

  let payload;
  try {
    payload = verifyRefreshToken(token);
  } catch {
    throw new ApiError(401, 'Invalid or expired refresh token');
  }

  const tokenHash = hashToken(token);
  const stored = await refreshTokenModel.findActiveByHash(tokenHash);
  if (!stored) throw new ApiError(401, 'Refresh token has been revoked');

  await refreshTokenModel.revokeByHash(tokenHash);
  const accessToken = await issueTokens(res, payload.sub);

  res.json({ accessToken });
});

const logout = asyncHandler(async (req, res) => {
  const token = req.cookies?.refreshToken;
  if (token) await refreshTokenModel.revokeByHash(hashToken(token));
  res.clearCookie('refreshToken');
  res.status(204).send();
});

const me = asyncHandler(async (req, res) => {
  const user = await userModel.findById(req.userId);
  if (!user) throw new ApiError(404, 'User not found');
  res.json({ user });
});

module.exports = { register, login, refresh, logout, me };
