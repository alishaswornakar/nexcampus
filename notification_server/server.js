// const express = require("express");
// const cors = require("cors");

// const { initializeApp, cert } = require("firebase-admin/app");
// const { getMessaging } = require("firebase-admin/messaging");
// const { getFirestore } = require("firebase-admin/firestore");

// const serviceAccount = require("./serviceAccountKey.json");

// initializeApp({
//   credential: cert(serviceAccount),
// });

// const db = getFirestore();

// const app = express();

// app.use(cors());
// app.use(express.json());

// app.use((req, res, next) => {
//   console.log(`${req.method} ${req.url}`);
//   next();
// });

// app.get("/", (req, res) => {
//   res.send("SERVER VERSION 2 - " + new Date().toISOString());
// });

// app.post("/sendToStudents", async (req, res) => {
//   try {
//     const { department, semester, title, body } = req.body;

//     console.log("Received Body:", req.body);
//     console.log("Department:", department);
//     console.log("Semester:", semester);

//     const snapshot = await db
//       .collection("users")
//       .where("role", "==", "student")
//       .where("department", "==", department)
//       .where("semester", "==", semester)
//       .get();

//     console.log("Students found:", snapshot.size);

//     const tokens = [];

//     snapshot.forEach((doc) => {
//       console.log(doc.id, doc.data());

//       const data = doc.data();

//       if (data.fcmToken) {
//         tokens.push(data.fcmToken);
//       }
//     });

//     console.log("Tokens:", tokens);

//     if (tokens.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: "No FCM tokens found.",
//       });
//     }

//     const response = await getMessaging().sendEachForMulticast({
//       tokens,
//       notification: {
//         title,
//         body,
//       },
//     });

//     console.log(response);

//    res.json({
//   server: "NEW SERVER",
//   success: true,
//   students: snapshot.size,
//   notificationsSent: response.successCount,
//   notificationsFailed: response.failureCount,
// });
//   } catch (e) {
//     console.error(e);

//     res.status(500).json({
//       success: false,
//       error: e.message,
//     });
//   }
// });

// app.listen(3000, () => {
//   console.log("🚀 Server running on port 3000");
// });