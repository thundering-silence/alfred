module.exports = {
    content: ['./src/**/*.{js,ts,jsx,tsx}'],
    plugins: [require('daisyui')],
    daisyui: {
        themes: [{
            mytheme: {
                primary: "#339989",
                secondary: "#7de2d1",
                accent: "#fcba04",
                neutral: "#fffafb",
                "base-100": "#FFFFFF",
                info: "#faedca",
                success: "#008000",
                warning: "#f9c74f",
                error: "#f25c54",
            },
        },],
    },
};
