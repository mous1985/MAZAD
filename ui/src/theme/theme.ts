import { extendTheme, defineStyle, defineStyleConfig } from '@chakra-ui/react';

// Palette de couleurs pour les modes clair et sombre
const colors = {
  mazad: {
    primary: '#1E88E5',
    secondary: '#0D47A1',
    background: {
      light: '#ffffff',
      dark: '#212121',
    },
    text: {
      light: '#213547',
      dark: '#E0F7FA',
    },
    button: {
      light: '#E3F2FD',
      dark: '#1a1a1a',
    },
  },
};

// Bouton principal avec des variantes dynamiques
const buttonPrimary = defineStyle((props: any) => ({
  background: props.colorMode === 'dark' ? colors.mazad.primary : colors.mazad.secondary,
  color: 'white',
  fontFamily: 'Fira Mono, sans-serif',
  fontWeight: 'bold',
  borderRadius: '8px',
  boxShadow: '2px 4px 6px rgba(0, 0, 0, 0.3)',
  _hover: {
    background: props.colorMode === 'dark' ? '#1565C0' : '#64B5F6',
  },
  _disabled: {
    background: props.colorMode === 'dark' ? '#BBDEFB' : '#E3F2FD',
    color: '#B0BEC5',
  },
}));

const buttonTheme = defineStyleConfig({
  variants: {
    buttonPrimary,
  },
});

// Extension du thème
const theme = extendTheme({
  components: {
    Text: {
      baseStyle: (props: any) => ({
        fontWeight: 'bold',
        color: props.colorMode === 'dark' ? colors.mazad.text.dark : colors.mazad.text.light,
      }),
    },
    Button: buttonTheme,
    Heading: {
      baseStyle: (props: any) => ({
        fontFamily: 'Fira Mono, sans-serif',
        color: props.colorMode === 'dark' ? colors.mazad.text.dark : colors.mazad.text.light,
        letterSpacing: 'wider',
      }),
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
      baseStyle: (props: any) => ({
        borderRadius: '10px',
        border: `1px solid ${colors.mazad.primary}`,
        padding: '20px',
        background: props.colorMode === 'dark' ? colors.mazad.background.dark : colors.mazad.background.light,
        boxShadow: '0 2px 10px rgba(0, 0, 0, 0.5)',
      }),
    },
    Flex: {
      baseStyle: {
        width: '100%',
      },
    },
  },
  styles: {
    global: (props: any) => ({
      body: {
        background: props.colorMode === 'dark'
          ? 'linear-gradient(135deg, #0D47A1 10%, #212121 90%)'
          : 'linear-gradient(135deg, #ffffff 10%, #E3F2FD 90%)',
        color: props.colorMode === 'dark' ? colors.mazad.text.dark : colors.mazad.text.light,
        fontWeight: 700,
        fontFamily: 'Fira Mono, sans-serif',
        animation: 'techBackground 10s ease infinite',
      },
      '@keyframes techBackground': {
        '0%': { backgroundPosition: '0% 50%' },
        '50%': { backgroundPosition: '100% 50%' },
        '100%': { backgroundPosition: '0% 50%' },
      },
    }),
  },
  colors, // Ajout de la palette au thème
  fonts: {
    body: 'Fira Mono, sans-serif',
    heading: 'Fira Mono, sans-serif',
  },
});

export default theme;
