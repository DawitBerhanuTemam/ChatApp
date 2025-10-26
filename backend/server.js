require('dotenv').config();
const express = require('express');
const cors = require('cors');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
    res.json({ message: 'Stripe Payment Server is running!' });
});

// Create PaymentIntent endpoint
app.post('/create-payment-intent', async (req, res) => {
    try {
        const { amount } = req.body;

        // Validate amount
        if (!amount || amount <= 0) {
            return res.status(400).json({
                error: 'Invalid amount. Amount must be greater than 0.'
            });
        }

        // Create a PaymentIntent with the order amount and currency
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // Convert to cents
            currency: 'usd',
            automatic_payment_methods: {
                enabled: true,
            },
            description: 'Fund payment via Flutter app',
        });

        res.json({
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
        });
    } catch (error) {
        console.error('Error creating payment intent:', error);
        res.status(500).json({
            error: error.message
        });
    }
});

// Create Checkout Session endpoint (for web)
app.post('/create-checkout-session', async (req, res) => {
    try {
        const { amount } = req.body;

        // Validate amount
        if (!amount || amount <= 0) {
            return res.status(400).json({
                error: 'Invalid amount. Amount must be greater than 0.'
            });
        }

        // Create a Checkout Session
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: 'usd',
                        product_data: {
                            name: 'Account Funding',
                            description: 'Add funds to your AbyssiniaBot account',
                        },
                        unit_amount: Math.round(amount * 100), // Convert to cents
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: `${req.headers.origin || 'http://localhost:50338'}?payment=success&session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${req.headers.origin || 'http://localhost:50338'}?payment=cancelled`,
        });

        res.json({
            sessionId: session.id,
            url: session.url,
        });
    } catch (error) {
        console.error('Error creating checkout session:', error);
        res.status(500).json({
            error: error.message
        });
    }
});

// Verify Checkout Session endpoint
app.get('/checkout-session/:sessionId', async (req, res) => {
    try {
        const { sessionId } = req.params;

        const session = await stripe.checkout.sessions.retrieve(sessionId);

        res.json({
            status: session.payment_status,
            amount: session.amount_total / 100,
            currency: session.currency,
            customerEmail: session.customer_email,
        });
    } catch (error) {
        console.error('Error retrieving checkout session:', error);
        res.status(500).json({
            error: error.message
        });
    }
});

// Confirm payment status endpoint
app.get('/payment-status/:paymentIntentId', async (req, res) => {
    try {
        const { paymentIntentId } = req.params;

        const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

        res.json({
            status: paymentIntent.status,
            amount: paymentIntent.amount / 100,
            currency: paymentIntent.currency,
        });
    } catch (error) {
        console.error('Error retrieving payment status:', error);
        res.status(500).json({
            error: error.message
        });
    }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Test the server at http://localhost:${PORT}`);
});
