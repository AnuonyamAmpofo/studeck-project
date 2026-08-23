const Anthropic = require('@anthropic-ai/sdk');
const env = require('../config/env');
const ApiError = require('../utils/ApiError');

const client = new Anthropic({ apiKey: env.anthropic.apiKey });

const QUIZ_SYSTEM_PROMPT = `You are a STEM quiz generator for a university study app called Studeck.
Given a topic and/or source material from a student's uploaded lecture slides, produce multiple-choice
questions that test real understanding, scoped to the material actually provided — not generic trivia.
Always respond with ONLY a JSON array — no prose, no markdown fences.

Each array element must have exactly this shape:
{
  "questionText": string,
  "options": { "A": string, "B": string, "C": string, "D": string },
  "correctOption": "A" | "B" | "C" | "D",
  "explanation": string
}`;

async function generateQuizQuestions({ topic, sourceMaterial, numQuestions = 5 }) {
  if (!env.anthropic.apiKey) {
    throw new ApiError(500, 'ANTHROPIC_API_KEY is not configured on the server');
  }

  const userPrompt = [
    `Generate ${numQuestions} multiple-choice questions.`,
    topic ? `Topic: ${topic}` : null,
    sourceMaterial ? `Source material (from uploaded lecture slides):\n${sourceMaterial}` : null,
  ]
    .filter(Boolean)
    .join('\n\n');

  const message = await client.messages.create({
    model: env.anthropic.model,
    max_tokens: 4096,
    system: QUIZ_SYSTEM_PROMPT,
    messages: [{ role: 'user', content: userPrompt }],
  });

  const raw = message.content
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('');

  let questions;
  try {
    questions = JSON.parse(raw);
  } catch {
    throw new ApiError(502, 'Claude returned a response that was not valid JSON', { raw });
  }

  if (!Array.isArray(questions) || questions.length === 0) {
    throw new ApiError(502, 'Claude did not return any questions');
  }

  return questions;
}

module.exports = { generateQuizQuestions };
