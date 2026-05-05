const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { createCanvas } = require("canvas");

admin.initializeApp();

exports.generateMatchCard = functions.firestore
    .document("matches/{matchId}")
    .onUpdate(async (change, context) => {
        const after = change.after.data();
        if (after.status !== "Finished") return null;

        const canvas = createCanvas(1200, 630);
        const ctx = canvas.getContext("2d");

        // Design the card
        ctx.fillStyle = "#0D0D0D";
        ctx.fillRect(0, 0, 1200, 630);

        ctx.fillStyle = "#00FFD1";
        ctx.font = "bold 60px 'Space Grotesk'";
        ctx.fillText("MATCH COMPLETE", 50, 100);

        // Add player scores
        ctx.fillStyle = "#FFFFFF";
        ctx.font = "40px 'Lexend'";
        let y = 250;
        for (const [uid, score] of Object.entries(after.scores)) {
            ctx.fillText(`${uid}: ${score}`, 100, y);
            y += 100;
        }

        // Save to Storage
        const buffer = canvas.toBuffer("image/png");
        const bucket = admin.storage().bucket();
        const file = bucket.file(`match_cards/${context.params.matchId}.png`);
        
        await file.save(buffer, {
            metadata: { contentType: "image/png" }
        });

        return change.after.ref.update({
            matchCardUrl: file.publicUrl()
        });
    });
