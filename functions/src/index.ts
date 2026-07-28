import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import OpenAI from "openai";
import cors from "cors";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

const corsHandler = cors({ origin: true });

export const chat = onRequest(
  {
    secrets: [OPENAI_API_KEY],
  },
  (req, res) => {
    corsHandler(req, res, async () => {
      try {
        if (req.method !== "POST") {
          res.status(405).send("Method Not Allowed");
          return;
        }

        const { message } = req.body;

        if (!message) {
          res.status(400).json({
            error: "Message is required",
          });
          return;
        }

        const client = new OpenAI({
          apiKey: OPENAI_API_KEY.value(),
        });

        const completion = await client.chat.completions.create({
          model: "gpt-4.1-mini",
          messages: [
            {
              role: "system",
              content:
                "You are NexCampus AI, a helpful university assistant.",
            },
            {
              role: "user",
              content: message,
            },
          ],
        });

        const reply =
          completion.choices[0].message.content ?? "No response.";

        res.json({
          reply,
        });
      } catch (error) {
        logger.error(error);

        res.status(500).json({
          error: "Internal Server Error",
        });
      }
    });
  }
);