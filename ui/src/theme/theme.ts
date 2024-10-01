import { extendTheme, defineStyle, defineStyleConfig } from '@chakra-ui/react';

const buttonPrimary = defineStyle({
  background: '#1E88E5',
  color: 'white',
  fontFamily: 'Fira Mono, sans-serif',
  fontWeight: 'bold',
  borderRadius: '8px',
  boxShadow: '2px 4px 6px rgba(0, 0, 0, 0.3)',

  _hover: {
    background: '#1565C0',
  },
  _disabled: {
    background: '#BBDEFB',
    color: '#B0BEC5',
  },
});

const buttonTheme = defineStyleConfig({
  variants: {
    buttonPrimary,
  },
});

const theme = extendTheme({
  components: {
    Text: {
      baseStyle: {
        fontWeight: 'bold',
        color: '#E0F7FA',
      },
    },
    Button: buttonTheme,
    Heading: {
      baseStyle: {
        fontFamily: 'Fira Mono, sans-serif',
        color: '#E3F2FD',
        letterSpacing: 'wider',
      },
      sizes: {
        xl: {
          fontSize: '3xl',
        },
        lg: {
          fontSize: '2xl',
        },
      },
    },
    Box: {
      baseStyle: {
        borderRadius: '10px',
        border: '1px solid #1E88E5',
        padding: '20px',
        background: '#212121',
        boxShadow: '0 2px 10px rgba(0, 0, 0, 0.5)',
      },
    },
  },
  styles: {
    global: {
      body: {
        background: 'linear-gradient(135deg, #0D47A1 10%, #212121 90%)',
        color: '#E0F7FA',
        fontWeight: 700,
        fontFamily: 'Fira Mono, sans-serif',
        animation: 'techBackground 10s ease infinite',
        margin: 0,             // Enlève les marges globales du body
        padding: 0,            // Enlève les paddings inutiles
        minHeight: '100vh',    // Assure que le body occupe toute la hauteur
        overflowX: 'hidden',   // Empêche le débordement horizontal
      },
      '@keyframes techBackground': {
        '0%': { backgroundPosition: '0% 50%' },
        '50%': { backgroundPosition: '100% 50%' },
        '100%': { backgroundPosition: '0% 50%' },
      },
    },
  },

  colors: {
    mazad: {
      primary: '#1E88E5',
      secondary: '#0D47A1',
      background: '#212121',
    },
  },
  fonts: {
    body: 'Fira Mono, sans-serif',
    heading: 'Fira Mono, sans-serif',
  },
});

export default theme;

