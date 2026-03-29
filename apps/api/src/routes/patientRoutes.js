import express from 'express';
import {
    getAllPatients,
    getPatientById,
    createPatient,
    updatePatient,
    deletePatient
} from '../controllers/patientController.js';

const router = express.Router();

router.get('/', getAllPatients);
router.get('/:id', getPatientById);
router.post('/', createPatient);
router.put('/:id', updatePatient);
router.delete('/:id', deletePatient);

export default router;