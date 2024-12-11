import { useColorMode } from '@chakra-ui/react';

export default function ThemeToggle() {
  const { colorMode, toggleColorMode } = useColorMode();
  return (
    <button
      onClick={toggleColorMode}
      className="p-2 rounded bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 hover:bg-gray-300 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
    >
      {colorMode === 'dark' ? 'Mode Clair' : 'Mode Sombre'}
    </button>
  );
}
