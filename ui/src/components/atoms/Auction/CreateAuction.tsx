
import { useState } from 'react';
import { Box, Button, Input, Textarea, useToast } from '@chakra-ui/react';
import { AdenaService } from '../../../services/adena/adena.ts';
import { IAdenaMessage } from '../../../services/adena/adena.types.ts';
import { EMessageType } from '../../../services/adena/adena.types.ts';
import Config from '../../../config.ts';

const CreateAuction = () => {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState<number>(0);
  const [beginTime, setBeginTime] = useState<string>(''); // New field for start time
  const [endTime, setEndTime] = useState<string>(''); // New field for end time
  const [isSubmitting, setIsSubmitting] = useState(false);
  const toast = useToast();

  const handleSubmit = async () => {
    setIsSubmitting(true);

    try {
      const accountInfo = await AdenaService.getAccountInfo();

      const beginTimestamp = Math.floor(new Date(beginTime).getTime() / 1000);
      const endTimestamp = Math.floor(new Date(endTime).getTime() / 1000);

      const messages: IAdenaMessage[] = [
        {
          type: EMessageType.MSG_CALL,
          value: {
            caller: accountInfo.address,
            send: `${price}ugnot`, // Prix en ugnot
            pkg_path: Config.REALM_PATH,
            func: 'CreateAuction',
            args: [title, description, beginTimestamp.toString() , endTimestamp.toString(), price.toString()]
          }
        }
      ];

      await AdenaService.sendTransaction(messages, 5000000);

      toast({
        title: 'Auction created successfully!',
        status: 'success',
        position: 'bottom-right',
        duration: 5000,
        isClosable: true,
      });

      // Réinitialiser les champs du formulaire après la création
      setTitle('');
      setDescription('');
      setPrice(0);
      setBeginTime('');
      setEndTime('');
    } catch (e) {
      console.error(e);
      toast({
        title: 'Unable to create auction',
        status: 'error',
        position: 'bottom-right',
        duration: 5000,
        isClosable: true,
      });
    }

    setIsSubmitting(false);
  };

  return (
    <Box>
      <Input
        placeholder="Auction Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <Textarea
        placeholder="Auction Description"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <Input
        placeholder="Starting Price"
        type="number"
        value={price}
        onChange={(e) => setPrice(Number(e.target.value))}
      />
      <Input
        placeholder="Begin Time (YYYY-MM-DD HH:mm:ss)"
        value={beginTime}
        onChange={(e) => setBeginTime(e.target.value)}
      />
      <Input
        placeholder="End Time (YYYY-MM-DD HH:mm:ss)"
        value={endTime}
        onChange={(e) => setEndTime(e.target.value)}
      />
      <Button
        onClick={handleSubmit}
        isLoading={isSubmitting}
        loadingText="CREATING AUCTION"
        variant="solid"
        colorScheme="teal"
        mt={4}
      >
        Create Auction
      </Button>
    </Box>
  );
};

export default CreateAuction;
