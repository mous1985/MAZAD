import { useState, useContext } from 'react';
import { Box, Input, Textarea, Button, FormControl, FormLabel, NumberInput, NumberInputField, useToast, Divider } from '@chakra-ui/react';
import { EMessageType, IAccountInfo } from "../../../services/adena/adena.types.ts";
import { AdenaService } from "../../../services/adena/adena.ts";
import ProviderContext from '../../../context/ProviderContext.ts';
import AccountContext from '../../../context/AccountContext.ts';
import Config from '../../../config.ts';

const CreateAuction = ({ onAuctionCreated }: { onAuctionCreated: () => void }) => {
  const { address } = useContext(AccountContext);
  const { provider } = useContext(ProviderContext);
  const [title, setTitle] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [startingPrice, setStartingPrice] = useState<number>(0);
  const [begin, setBegin] = useState<string>('');
  const [end, setEnd] = useState<string>('');
  const [image, setImage] = useState<File | null>(null);
  const toast = useToast();

  const handleImageChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files[0]) {
      setImage(event.target.files[0]);
    }
  };

  const handleCreateAuction = async () => {
    const parsedBegin = Date.parse(begin);
    const parsedEnd = Date.parse(end);
    if (isNaN(parsedBegin) || isNaN(parsedEnd)) {
      console.error('Invalid dates provided');
      return;
    }
    if (!provider || !address) {
      toast({
        title: 'Connection Error',
        description: 'Please connect your wallet first.',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
      return;
    }

    try {
      const accountInfo: IAccountInfo = await AdenaService.getAccountInfo();

      const beginTime = Math.floor(new Date(parsedBegin).getTime() / 1000); // Convert to Unix timestamp
      const endTime = Math.floor(new Date(parsedEnd).getTime() / 1000);
      // Send transaction to create the auction
      await AdenaService.sendTransaction(
        [
          {
            type: EMessageType.MSG_CALL,
            value: {
              caller: accountInfo.address,
              send: '',
              pkg_path: Config.REALM_PATH,
              func: 'CreateAuction',
              args: [
                title,
                description,
                `${beginTime}`,
                `${endTime}`,
                `${startingPrice}`,
              ],
            },
          },
        ],
        2000000
      );

      toast({
        title: 'Auction Created',
        description: 'Your auction has been created successfully!',
        status: 'success',
        duration: 5000,
        isClosable: true,
      });

      onAuctionCreated(); // Call the callback to refresh auction data
    } catch (error) {
      console.error('Error creating auction:', error);
      toast({
        title: 'Error',
        description: 'There was an error creating the auction.',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    }
  };

  return (
    <Box maxW="md" mx="auto" mt={8} p={6} borderRadius="lg" borderWidth="1px">
      {/* Image Upload Section */}
      <FormControl id="image" mb={4}>
        <FormLabel>Upload Image</FormLabel>
        <Input type="file" onChange={handleImageChange} />
      </FormControl>

      <Divider my={6} />

      {/* Auction Information Section */}
      <FormControl id="title" mb={4}>
        <FormLabel>Title</FormLabel>
        <Input
          placeholder="Auction Title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
      </FormControl>

      <FormControl id="description" mb={4}>
        <FormLabel>Description</FormLabel>
        <Textarea
          placeholder="Auction Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </FormControl>

      <FormControl id="startingPrice" mb={4}>
        <FormLabel>Starting Price (GNOT)</FormLabel>
        <NumberInput min={0} value={startingPrice} onChange={(valueString) => setStartingPrice(Number(valueString))}>
          <NumberInputField />
        </NumberInput>
      </FormControl>

      <FormControl id="begin" mb={4}>
        <FormLabel>Begin Time</FormLabel>
        <Input
          type="datetime-local"
          value={begin}
          onChange={(e) => setBegin(e.target.value)}
        />
      </FormControl>

      <FormControl id="end" mb={4}>
        <FormLabel>End Time</FormLabel>
        <Input
          type="datetime-local"
          value={end}
          onChange={(e) => setEnd(e.target.value)}
        />
      </FormControl>

      <Button colorScheme="blue" onClick={handleCreateAuction}>
        Create Auction
      </Button>
    </Box>
  );
};

export default CreateAuction;